local addonName, ns = ...

-- Lib used in this addon:
-- https://www.wowace.com/projects/libbabble-subzone-3-0

-- TODO:
-- play with https://wow.gamepedia.com/ItemMixin#Methods

-- Imports
local Utility = ns.Utility
local Const = ns.Const
local Engine = ns.Engine
local Locales = ns.Locales

-- Localize functions
local string_match = string.match
local string_find = string.find
local string_format = string.format

local C_Container_GetContainerNumSlots
local C_Container_GetContainerItemId

local C_Item_GetItemCount
local C_Item_GetItemInfo

-- For patch 10.2.6 / 3.4.3 / 4.4.0
if C_Item and C_Item.GetItemCount then
    C_Item_GetItemCount = C_Item.GetItemCount
else
    C_Item_GetItemCount = GetItemCount
end
if C_Item and C_Item.GetItemInfo then
    C_Item_GetItemInfo = C_Item.GetItemInfo
else
    C_Item_GetItemInfo = GetItemInfo
end

-- For patch 10.0.2 / 3.4.1
if C_Container and C_Container.GetContainerNumSlots then
    C_Container_GetContainerNumSlots = C_Container.GetContainerNumSlots
else
    C_Container_GetContainerNumSlots = GetContainerNumSlots
end

-- For patch 10.0.2 / 3.4.1
if C_Container and C_Container.GetContainerItemInfo then
    C_Container_GetContainerItemId = function (bag, slot)
        local containerInfo = C_Container.GetContainerItemInfo(bag, slot)
        if containerInfo then
            return containerInfo.itemID
        end
        return nil
    end
else
    C_Container_GetContainerItemId = function(bag, slot)
        local _, _, _, _, _, _, _, _, _, itemId = GetContainerItemInfo(bag, slot)
        return itemId
    end
end

-- Local namespace
local Core = {}

-- Some init
Core.nextScan = 0
Core.nextScanTimer = nil
Core.bests = {}
Core.availableItems = {}
Core.scanAttempt = {}
Core.firstRun = true
Core.scanning = false
Core.itemCache = {}
Core.ignoredItemCache = {}
Core.customMacros = {}

local Buffet = CreateFrame("frame")
Core.Buffet = Buffet

Buffet:SetScript("OnEvent", function(self, event, ...)
    if self[event] then
        return self[event](self, event, ...)
    end
end)

function Buffet:ADDON_LOADED(event, addon)
    if addon:lower() ~= "buffet" then
        return
    end
    self:UnregisterEvent("ADDON_LOADED")

    if C_AddOns and C_AddOns.GetAddOnMetadata then
        Core.Version = C_AddOns.GetAddOnMetadata(addonName, 'Version');
    else
        Core.Version = GetAddOnMetadata(addonName, 'Version');
    end

    -- load saved variables
    BuffetItemDB = setmetatable(BuffetItemDB or {}, { __index = Const.ItemDBdefaults })
    BuffetDB = setmetatable(BuffetDB or {}, { __index = Const.DBdefaults })
    Core.db = BuffetDB

    local _, build = GetBuildInfo()
    local currBuild, prevBuild, buffetVersion = tonumber(build), BuffetItemDB.build, BuffetItemDB.version

    -- load items cache only if we are running the same build (client and addon)
    if prevBuild and (prevBuild == currBuild) and buffetVersion and (buffetVersion == Core.Version) then
        Core.itemCache = BuffetItemDB.itemCache or {}
    else
        Utility.Print("Cache has been cleared due to version update.")
    end

    Core.nextScanDelay = BuffetItemDB.nextScanDelay

    -- clean saved variables
    BuffetItemDB.build = currBuild
    BuffetItemDB.itemCache = Core.itemCache
    BuffetItemDB.nextScanDelay = Core.nextScanDelay
    BuffetItemDB.version = Core.Version

    for k, v in pairs(BuffetItemDB.customMacros) do
        Core.customMacros[k] = {}
        Core.customMacros[k].key = v.name
        Core.customMacros[k].name = v.name
        Core.customMacros[k].source = v.source
        Core.customMacros[k].chunk = nil
        Core.customMacros[k].error = false
        Core.customMacros[k].body = nil
        Core.customMacros[k].icon = nil
    end

    Core:ResetBest()
    Core:ResetAvailableItems()

    self.ADDON_LOADED = nil

    if IsLoggedIn() then
        self:PLAYER_LOGIN()
    else
        self:RegisterEvent("PLAYER_LOGIN")
    end
end

function Buffet:PLAYER_LOGIN()
    self:UnregisterEvent("PLAYER_LOGIN")

    self:RegisterEvent("PLAYER_LOGOUT")
    self:RegisterEvent("PLAYER_REGEN_ENABLED")
    self:RegisterEvent("PLAYER_LEVEL_UP")
    self:RegisterEvent("BAG_UPDATE_DELAYED")
    self:RegisterEvent("UNIT_MAXHEALTH")
    self:RegisterEvent("UNIT_MAXPOWER")
    self:RegisterEvent("ZONE_CHANGED")
    self:RegisterEvent("ZONE_CHANGED_NEW_AREA")


    self.PLAYER_LOGIN = nil

    -- init few values
    Core.playerLevel = UnitLevel("player")
    Core.playerHealth = UnitHealthMax("player")
    Core.playerMana = UnitPowerMax("player")

    Utility.LoadProfessions()

    if Core.db.showVersion then
        Utility.Print(Core.Version, "Loaded!")
    end

    if Utility.IsClassic then
        Utility.Debug("Classic mode enabled")
    elseif Utility.IsTBC then
        Utility.Debug("TBC mode enabled")
    elseif Utility.WLK then
        Utility.Debug("WLK mode enabled")
    elseif Utility.IsCataclysm then
        Utility.Debug("Cataclysm mode enabled")
    elseif Utility.IsMists then
        Utility.Debug("Mists mode enabled")
    elseif Utility.IsRetail then
        Utility.Debug("Retail mode enabled")
    end

    Core:QueueScan()
end

function Buffet:PLAYER_LOGOUT()
    -- Save BuffetDB
    for i, v in pairs(Const.DBdefaults) do
        if Core.db[i] == v then
            Core.db[i] = nil
        end
    end
    for i, _ in pairs(Core.db) do
        if Const.DBdefaults[i] == nil then
            Core.db[i] = nil
        end
    end

    -- Save BuffetItemDB
    BuffetItemDB.itemCache = Core.itemCache
    BuffetItemDB.nextScanDelay = Core.nextScanDelay
    BuffetItemDB.customMacros = {}
    for k, v in pairs(Core.customMacros) do
        BuffetItemDB.customMacros[k] = {}
        BuffetItemDB.customMacros[k].name = v.name
        BuffetItemDB.customMacros[k].source = v.source
    end

    for i, v in pairs(Const.ItemDBdefaults) do
        if BuffetItemDB[i] == v then
            BuffetItemDB[i] = nil
        end
    end
    for i, _ in pairs(BuffetItemDB) do
        if not Const.ItemDBdefaults[i] then
            BuffetItemDB[i] = nil
        end
    end
end

function Buffet:PLAYER_REGEN_ENABLED()
    if Core.dirty then
        Core:EnableDelayedScan()
    end
end

function Buffet:ZONE_CHANGED()
    Core:QueueScan()
end
function Buffet:ZONE_CHANGED_NEW_AREA()
    Buffet:ZONE_CHANGED()
end

function Buffet:BAG_UPDATE_DELAYED()
    Core:QueueScan()
end

function Buffet:PLAYER_LEVEL_UP(event, arg1)
    Core.playerLevel = arg1
    Core:QueueScan()
end

function Buffet:UNIT_MAXHEALTH(event, arg1)
    if arg1 == "player" then
        Core.playerHealth = UnitHealthMax("player")
        Core:QueueScan()
    end
end

function Buffet:UNIT_MAXPOWER(event, arg1, arg2)
    if (arg1 == "player") and (arg2 == "MANA") then
        Core.playerMana = UnitPowerMax("player")
        Core:QueueScan()
    end
end

function Core:ResetBest()
    for _, v in pairs(Const.BestCategories) do
        Core.bests[v] = { val = -1, stack = -1, id = nil }
    end
end

function Core:ResetAvailableItems()
    for _, v in pairs(Const.BestCategories) do
        Core.availableItems[v] = nil
    end
end

function Core:QueueScan()
    if InCombatLockdown() then
        self.dirty = true -- try when out of combat (regen event)
    else
        self:EnableDelayedScan()
    end
end

function Core:EnableDelayedScan()
    if self.nextScanTimer then
        self.nextScanTimer:Cancel()
    end
    -- restart timer each time we queue a scan
    self.nextScanTimer = C_Timer.NewTimer(Core.nextScanDelay, self.OnTimerCallback)
end

function Core:OnTimerCallback()
    Core.nextScanTimer = nil
    if InCombatLockdown() then
        Core.dirty = true
    else
        Core:Scan()
    end
end

function Core:Scan()
    if Core.scanning then
        return
    end

    Core.scanning = true

    Utility.Debug("Scanning bags...")

    -- clear previous bests
    self:ResetBest()
    self:ResetAvailableItems()

    local delayedScanRequired = false
    local itemIds = {}

    -- scan bags and build unique list of item ids
    for bag = 0, 4 do
        for slot = 1, C_Container_GetContainerNumSlots(bag) do
            local itemId = C_Container_GetContainerItemId(bag, slot)
            -- slot not empty
            if itemId then
                if not Core.ignoredItemCache[itemId] and not Core.db.ignoredItems[itemId] then
                    if not itemIds[itemId] then
                        -- get total count for this item id
                        itemIds[itemId] = C_Item_GetItemCount(itemId)
                    end
                end
            end
        end
    end

    -- for each item id
    for k, v in pairs(itemIds) do
        local itemId, itemCount = k, v

        -- get item info
        local itemName, itemLink, _, itemLevel, itemMinLevel, _, _, _, _, _, _, itemClassId, itemSubClassId = C_Item_GetItemInfo(itemId)
        -- Utility.Debug("Debug:", itemId, itemName, itemClassId, itemSubClassId)

        -- ensure itemMinLevel is not nil
        itemMinLevel = itemMinLevel or 0

        -- treat only interesting items
        if (itemId ~= 12662) and (itemId ~= 20520) and itemLink and (itemMinLevel <= self.playerLevel) and (Engine.IsValidItemClasses(itemClassId, itemSubClassId)) then
            local itemData = self:MakeNewItemData(itemId, itemClassId, itemSubClassId)

            local itemFoundInCache = false

            -- check cache for item
            if Core.itemCache[itemId] then
                itemData = Core.itemCache[itemId]

                local validHealth = not itemData.isHealth or (itemData.isHealth and (itemData.health and itemData.health > 0))
                local validMana   = not itemData.isMana   or (itemData.isMana   and (itemData.mana   and itemData.mana   > 0))
                itemFoundInCache = validHealth or validMana
            end

            -- if not found, scan and parse tooltip
            if not itemFoundInCache then
                -- parse tooltip values
                local texts = Engine.ScanTooltip(itemLink)

                if (Utility.TableCount(texts) <= 0) and (not Core.scanAttempt[itemId] or Core.scanAttempt[itemId] < 5) then
                    if Core.scanAttempt[itemId] then
                        Core.scanAttempt[itemId] = Core.scanAttempt[itemId] + 1
                    else
                        Core.scanAttempt[itemId] = 1
                    end
                    delayedScanRequired = true
                else
                    if Core.scanAttempt[itemId] and (Core.scanAttempt[itemId] >= 5) then
                        Utility.Debug("5 failed attempt on: ", itemLink, ", item ignored from next scans")
                        Core.ignoredItemCache[itemId] = itemLink
                    else
                        itemData = Engine.ParseTexts(texts, itemData)
                        -- Utility.Debug(itemData)

                        local validHealth = (itemData.isHealth and (itemData.health and (itemData.health > 0)))
                        local validMana   = (itemData.isMana   and (itemData.mana   and (itemData.mana   > 0)))

                        if validHealth or validMana then
                            Core.itemCache[itemId] = itemData
                            itemFoundInCache = true
                        else
                            if Core.scanAttempt[itemId] then
                                Core.scanAttempt[itemId] = Core.scanAttempt[itemId] + 1
                            else
                                Core.scanAttempt[itemId] = 1
                            end
                            delayedScanRequired = true
                        end
                    end
                end
            end

            -- if item is usable
            if itemFoundInCache and ((itemData.health and (itemData.health > 0)) or (itemData.mana and (itemData.mana > 0))) then
                -- Utility.Debug(itemName, itemData)

                local isRestricted, hasRestriction = Engine.CheckRestriction(itemId)

                -- set found values to best
                if not isRestricted then
                    local health = 0
                    local mana = 0
                    -- update pct values
                    if itemData.isPct then
                        if (itemData.health and (itemData.health > 0)) then
                            health = itemData.health * Core.playerHealth
                        end
                        if (itemData.mana and (itemData.mana > 0)) then
                            mana = itemData.mana * Core.playerMana
                        end
                    else
                        if (itemData.health and (itemData.health > 0)) then
                            health = itemData.health
                        end
                        if (itemData.mana and (itemData.mana > 0)) then
                            mana = itemData.mana
                        end
                    end
                    if itemData.isOverTime and itemData.overTime and (itemData.overTime > 0) then
                        if (health and (health > 0)) then
                            health = health * itemData.overTime
                        end
                        if (mana and (mana > 0)) then
                            mana = mana * itemData.overTime
                        end
                    end

                    -- set bests
                    local healthCats, manaCats = Engine.GetCategories(itemData)
                    if healthCats then
                        for _, v2 in pairs(healthCats) do
                            self:SetBest(v2, itemId, health, itemCount, hasRestriction)
                            self:SetAvailable(v2, itemId, health, itemCount, hasRestriction)
                        end
                    end
                    if manaCats then
                        for _, v2 in pairs(manaCats) do
                            self:SetBest(v2, itemId, mana, itemCount, hasRestriction)
                            self:SetAvailable(v2, itemId, mana, itemCount, hasRestriction)
                        end
                    end
                end
            end
        end
    end

    -- 12662 demonic rune
    if itemIds[12662] and (itemIds[12662] > 0) then
        local _, _, _, _, itemMinLevel = C_Item_GetItemInfo(12662)
        if itemMinLevel <= self.playerLevel then
            local runeValue = 0
            if Utility.IsClassic or Utility.IsTBC or Utility.IsWLK or Utility.IsCataclysm then
                runeValue = 1200
            end
            if Utility.IsMists then
                runeValue = 1210
            end
            if Utility.IsRetail then
                runeValue = 688
            end
            self:SetBest(Const.BestCategories.rune, 12662, runeValue, itemIds[12662])
            self:SetAvailable(Const.BestCategories.rune, 12662, runeValue, itemIds[12662])
        end
    end

    -- 20520 dark rune
    if itemIds[20520] and (itemIds[20520] > 0) then
        local _, _, _, _, itemMinLevel = C_Item_GetItemInfo(20520)
        if itemMinLevel <= self.playerLevel then
            local runeValue = 0
            if Utility.IsClassic or Utility.IsTBC or Utility.IsWLK or Utility.IsCataclysm then
                runeValue = 1199 -- health set to 1199 to prioritize demonic rune over dark rune
            end
            if Utility.IsMists then
                runeValue = 1200
            end
            if Utility.IsRetail then
                runeValue = 546
            end
            self:SetBest(Const.BestCategories.rune, 20520, runeValue, itemIds[20520])
            self:SetAvailable(Const.BestCategories.rune, 20520, runeValue, itemIds[20520])
        end
    end

    local bestFood = Core.bests.food.id
    local bestDrink = Core.bests.water.id
    if Core.db.wellFed then
        if Core.bests.wellfedfood.id then
            if not Core.bests.food.id or (Core.bests.wellfedfood.val > Core.bests.food.val) then
                bestFood = Core.bests.wellfedfood.id
            end
        end
        if Core.bests.wellfedwater.id then
            if not Core.bests.water.id or (Core.bests.wellfedwater.val > Core.bests.water.val) then
                bestDrink = Core.bests.wellfedwater.id
            end
        end
    end

    local food = Core.bests.percfood.id or bestFood
    local water = Core.bests.percwater.id or bestDrink

    local healthPotion = Core.bests.hppot.id
    if Core.db.isToxicPotion then
        if Core.bests.toxicpot.id then
            if not Core.bests.hppot.id or (Core.bests.toxicpot.val > Core.bests.hppot.val) then
                healthPotion = Core.bests.toxicpot.id
            end
        end
    end

    self:EditDefault(Const.MacroNames.defaultHP, Core.db.macroHP, food, Core.bests.healthstone.id, healthPotion, Core.bests.bandage.id)
    self:EditDefault(Const.MacroNames.defaultMP, Core.db.macroMP, water, Core.bests.managem.id, Core.bests.mppot.id, Core.bests.rune.id)

    self:EditFoodOnly(Const.MacroNames.foodOnlyHP, Core.db.macroHP, food)
    self:EditFoodOnly(Const.MacroNames.drinkOnlyMP, Core.db.macroMP, water)

    self:EditConsumable(Const.MacroNames.consumableHP, Core.db.macroHP, Core.bests.healthstone.id, healthPotion, Core.bests.bandage.id)
    self:EditConsumable(Const.MacroNames.consumableMP, Core.db.macroMP, Core.bests.managem.id, Core.bests.mppot.id, Core.bests.rune.id)

    -- Update custom macros
    for _, macro in pairs(Core.customMacros) do
        if not macro.error then
            -- check if the macro exists
            local macroId = GetMacroIndexByName(macro.name)
            if macroId > 0 then
                Core:CompileSource(macro)
                local body, icon = Core:RunChunk(macro)
                if body and (macro.body ~= body or macro.icon ~= icon) then
                    macro.body = body
                    macro.icon = icon
                    EditMacro(macroId, macro.name, icon or "INV_Misc_QuestionMark", body, 1)
                    Utility.Debug("Custom Macro: " .. macro.name .. " has been updated successfully")
                end
            end
        end
    end

    -- if we didn't found any food or water, and it is the first run, queue a delayed scan
    if (not food and not water) and Core.firstRun then
        Core.firstRun = false
        delayedScanRequired = true
    end

    Core.scanning = false
    Core.dirty = false

    if delayedScanRequired then
        self:QueueScan()
    end
end

function Core:RunChunk(macro)
    if macro.error or macro.chunk == nil then
        return nil, nil
    end

    local success, ret1, ret2 = pcall(macro.chunk, Core:BestsBeautifier(), Core.itemCache, Core:AvailableItemsBeautifier())
    if success then
        return ret1, ret2
    else
        macro.error = true
        macro.chunk = nil
        macro.icon = nil
        Utility.Print("Custom Macro: Unable to execute " .. macro.name ..", please check the source")
        Utility.Print("Error: " .. (ret1 or "unknown"))
        return nil, nil
    end
end

function Core:CompileSource(macro)
    if macro.error then
        macro.chunk = nil
        return
    end

    local chunk, errorMessage = loadstring(macro.source, macro.name)
    if chunk then
        macro.chunk = chunk
    else
        macro.chunk = nil
        macro.error = true
        macro.icon = nil
        Utility.Print("Custom Macro: Unable to compile " .. macro.name ..", please check the source")
        Utility.Print("Error: " .. errorMessage)
    end
end

function Core:MakeNewItemData(itemId, itemClassId, itemSubClassId)
    local itemData = {}
    itemData.itemId = itemId
    itemData.isHealth = false
    itemData.isMana = false
    itemData.isConjured = false
    itemData.isWellFed = false
    itemData.isPct = false
    itemData.isFoodAndDrink = false
    itemData.isPotion = false
    itemData.isToxicPotion = false
    itemData.isBandage = false
    itemData.isRestricted = false
    itemData.isOverTime = false
    itemData.health = 0.0
    itemData.mana = 0.0
    itemData.overTime = 0
    itemData.itemClassId = itemClassId
    itemData.itemSubClassId = itemSubClassId
    return itemData
end

function Core:BestsBeautifier()
    local bests = {}
    if Core.bests then
        bests.bandage = Core.bests.bandage.id
        bests.rune = Core.bests.rune.id
        bests.conjuredFood = Core.bests.percfood.id
        bests.conjuredDrink = Core.bests.percwater.id
        bests.food = Core.bests.food.id
        bests.drink = Core.bests.water.id
        bests.healthstone = Core.bests.healthstone.id
        bests.manaGem = Core.bests.managem.id
        bests.healthPotion = Core.bests.hppot.id
        bests.toxicPotion = Core.bests.toxicpot.id
        bests.manaPotion = Core.bests.mppot.id
        bests.wellFedFood = Core.bests.wellfedfood.id
        bests.wellFedDrink = Core.bests.wellfedwater.id
    end
    return bests
end

function Core:AvailableItemsBeautifier()
    local comparer = function (item1, item2)
        if item1.value == item2.value then
            return item1.itemCount > item2.itemCount
        end
        return item1.value > item2.value
    end

    local items = {}
    if Core.availableItems then
        if Core.availableItems[Const.BestCategories.bandage] then
            items.bandage = Core.availableItems[Const.BestCategories.bandage]
        end
        if Core.availableItems[Const.BestCategories.rune] then
            items.rune = Core.availableItems[Const.BestCategories.rune]
        end
        if Core.availableItems[Const.BestCategories.hppot] then
            items.healthPotion = Core.availableItems[Const.BestCategories.hppot]
        end
        if Core.availableItems[Const.BestCategories.toxicpot] then
            items.toxicPotion = Core.availableItems[Const.BestCategories.toxicpot]
        end
        if Core.availableItems[Const.BestCategories.mppot] then
            items.manaPotion = Core.availableItems[Const.BestCategories.mppot]
        end
        if Core.availableItems[Const.BestCategories.healthstone] then
            items.healthstone = Core.availableItems[Const.BestCategories.healthstone]
        end
        if Core.availableItems[Const.BestCategories.managem] then
            items.manaGem = Core.availableItems[Const.BestCategories.managem]
        end
        if Core.availableItems[Const.BestCategories.water] then
            items.drink = Core.availableItems[Const.BestCategories.water]
        end
        if Core.availableItems[Const.BestCategories.food] then
            items.food = Core.availableItems[Const.BestCategories.food]
        end
        if Core.availableItems[Const.BestCategories.percfood] then
            items.conjuredFood = Core.availableItems[Const.BestCategories.percfood]
        end
        if Core.availableItems[Const.BestCategories.percwater] then
            items.conjuredDrink = Core.availableItems[Const.BestCategories.percwater]
        end
        if Core.availableItems[Const.BestCategories.wellfedfood] then
            items.wellFedFood = Core.availableItems[Const.BestCategories.wellfedfood]
        end
        if Core.availableItems[Const.BestCategories.wellfedwater] then
            items.wellFedDrink = Core.availableItems[Const.BestCategories.wellfedwater]
        end

        for k, _ in pairs(items) do
            table.sort(items[k], comparer)
        end
    end

    return items
end

function Core:Edit(name, substring, food, pot, mod)
    local macroid = GetMacroIndexByName(name)
    if not macroid then
        return
    end

    local body = "/use "
    if mod then
        body = body .. "[mod,target=player] item:" .. mod .. "; "
    end
    if Core.db.combat and pot then
        body = body .. "[combat] item:" .. pot .. "; "
    end
    body = body .. "item:" .. (food or "6948")

    EditMacro(macroid, name, "INV_Misc_QuestionMark", substring:gsub("%%MACRO%%", body), 1)
end

function Core:EditDefault(name, substring, food, conjured, pot, mod)
    local macroid = GetMacroIndexByName(name)
    if not macroid then
        return
    end

    local cast = "/cast "

    if mod then -- bandage / rune
        if Core.db.modSpecial and Core.db.modSpecial ~= "" then
            cast = cast .. "[" .. Core.db.modSpecial .. ",target=player] item:" .. mod .. "; "
        else
            cast = cast .. "[target=player] item:" .. mod .. "; "
        end
    end

    if Core.db.combat and conjured then -- health stone / mana gem
        if Core.db.modConjured and Core.db.modConjured ~= "" then
            cast = cast .. "[combat," .. Core.db.modConjured .. "] item:" .. conjured .. "; "
        else
            cast = cast .. "[combat] item:" .. conjured .. "; "
        end
    end

    if Core.db.combat and pot then
        if Core.db.modPotion and Core.db.modPotion ~= "" then
            cast = cast .. "[combat," .. Core.db.modPotion .. "] item:" .. pot .. "; "
        else
            cast = cast .. "[combat] item:" .. pot .. "; "
        end
    end

    if food then
        cast = cast .. "item:" .. food
    else
        if Core.db.hearthstone then
            cast = cast .. "item:6948"
        end
    end

    if cast == "/cast " then
        cast = ""
    end

    EditMacro(macroid, name, "INV_Misc_QuestionMark", substring:gsub("%%MACRO%%", cast), 1)
end

function Core:EditFoodOnly(name, substring, food)
    local macroid = GetMacroIndexByName(name)
    if not macroid then
        return
    end

    --    Utility.Debug("food: ", food)

    local cast = "/cast "

    if food then
        cast = cast .. "item:" .. food
    else
        if Core.db.hearthstone then
            cast = cast .. "item:6948"
        end
    end

    if cast == "/cast " then
        cast = ""
    end

    -- Utility.Debug("foodonly: ", cast)

    EditMacro(macroid, name, "INV_Misc_QuestionMark", substring:gsub("%%MACRO%%", cast), 1)
end

function Core:EditConsumable(name, substring, conjured, pot, mod)
    local macroid = GetMacroIndexByName(name)
    if not macroid then
        return
    end

    --    Utility.Debug("conjured: ", conjured)
    --    Utility.Debug("pot: ", pot)
    --    Utility.Debug("mod: ", mod)

    local cast = "/cast "

    if mod then -- bandage / rune
        if Core.db.consModSpecial and Core.db.consModSpecial ~= "" then
            cast = cast .. "[" .. Core.db.consModSpecial .. ",target=player] item:" .. mod .. "; "
        else
            cast = cast .. "[target=player] item:" .. mod .. "; "
        end
    end

    if conjured then -- health stone / mana gem
        if Core.db.consModConjured and Core.db.consModConjured ~= "" then
            cast = cast .. "[" .. Core.db.consModConjured .. "] item:" .. conjured .. "; "
        else
            cast = cast .. "item:" .. conjured .. "; "
        end
    end

    if pot then
        if Core.db.consModPotion and Core.db.consModPotion ~= "" then
            cast = cast .. "[" .. Core.db.consModPotion .. "] item:" .. pot .. "; "
        else
            cast = cast .. "item:" .. pot
        end
    else
        if Core.db.hearthstone then
            cast = cast .. "item:6948"
        end
    end

    if cast == "/cast " then
        cast = ""
    end

    -- Utility.Debug("consumable: ", cast)

    EditMacro(macroid, name, "INV_Misc_QuestionMark", substring:gsub("%%MACRO%%", cast), 1)
end

function Core:SetBest(cat, id, value, stack, hasRestriction)
    local best = Core.bests[cat];
    if best and id then
        if (hasRestriction and (value >= best.val)) or ((value > best.val) or ((value == best.val) and (best.stack > stack))) then
            best.val = value
            best.id = id
            best.stack = stack
        end
    end
end

function Core:SetAvailable(cat, id, value, stack, hasRestriction)
    if not Core.availableItems[cat] then
        Core.availableItems[cat] = { }
    end
    local item = { }
    item.value = value
    item.itemId = id
    item.itemCount = stack
    table.insert(Core.availableItems[cat], item)
end

function Core:SlashHandler(message, editbox)
    local _, _, cmd, args = string_find(message, "%s?([a-z-]+)%s?(.*)")

    if cmd == "combat" then
        local combat = args or nil
        if combat ~= nil and combat ~= "" then
            combat = tonumber(combat)
            Core.db.combat = (combat == 1)
            self:QueueScan()
        end
        if Core.db.combat then
            Utility.Print("combat mode: enable")
        else
            Utility.Print("combat mode: disable")
        end
    elseif cmd == "clear" then
        Core.scanAttempt = {}
        Core.itemCache = {}
        Core.ignoredItemCache = {}
        Core.availableItems = {}
        Utility.Print("Cache cleared!")
        Utility.Print("Rescanning bags...")
        self:QueueScan()
    elseif cmd == "scan" then
        Utility.Print("Scanning bags...")
        self:QueueScan()
    elseif cmd == "delay" then
        local delay = args or nil
        if delay and delay ~= "" then
            delay = tonumber(delay)
            if type(delay) == "number" and delay >= 0.1 and delay <= 10 then
                Utility.Print("next scan delay set to", delay, "seconds")
                Core.nextScanDelay = delay
            else
                Utility.Print("invalid value, delay must be a number between 0.1 and 10")
            end
        else
            Utility.Print("next scan delay current value is", Core.nextScanDelay)
        end
    elseif cmd == "ignore-add" then
        local itemString = args or nil
        if itemString and itemString ~= "" then
            local _, itemLink = GetItemInfo(itemString)
            if itemLink then
                local itemId = string_match(itemLink, "item:([%d]+)")
                if itemId then
                    itemId = tonumber(itemId)
                    if not Core.db.ignoredItems[itemId] then
                        Core.db.ignoredItems[itemId] = itemLink
                        Utility.Print(itemLink .. " added to ignore list")
                        self:QueueScan()
                    else
                        Utility.Print(itemLink .. " is already in the ignore list")
                    end
                end
            end
        else
            Utility.Print("Invalid argument")
        end
    elseif cmd == "ignore-remove" then
        local itemString = args or nil
        if itemString and itemString ~= "" then
            local _, itemLink = GetItemInfo(itemString)
            if itemLink then
                local itemId = string_match(itemLink, "item:([%d]+)")
                if itemId then
                    itemId = tonumber(itemId)
                    if Core.db.ignoredItems[itemId] then
                        Core.db.ignoredItems[itemId] = nil
                        Utility.Print(itemLink .. " removed from ignore list")
                        self:QueueScan()
                    else
                        Utility.Print(itemLink .. " is not in the ignore list")
                    end
                end
            end
        else
            Utility.Print("Invalid argument")
        end
    elseif cmd == "ignore-clear" then
        Core.db.ignoredItems = {}
        Utility.Print("The ignore list has been emptied.")
        self:QueueScan()
    elseif cmd == "ignore-list" then
        if Utility.TableCount(Core.db.ignoredItems) > 0 then
            Utility.Print("The following items are in the ignore list:")
            for k,v in pairs(Core.db.ignoredItems) do
                Utility.Print(v)
            end
        else
            Utility.Print("The ignore list is empty.")
        end
    elseif cmd == "info" then
        local itemString = args or nil
        if itemString then
            local _, itemLink = GetItemInfo(itemString)
            if itemLink then
                local itemId = string_match(itemLink, "item:([%d]+)")
                if itemId then
                    itemId = tonumber(itemId)
                    if Core.itemCache[itemId] then
                        local data = Core.itemCache[itemId]
                        data.isRestricted = Engine.CheckRestriction(itemId)
                        self:PrintItemData(itemString, data)
                        data.isRestricted = false
                    else
                        Utility.Print("Item " .. itemString .. ": Not in cache")
                    end
                end
            end
        else
            Utility.Print("Invalid argument")
        end
    elseif cmd == "session-ignored" then
        Utility.Print("The following items have been automatically ignored from scans for this session:")
        for k,v in pairs(Core.ignoredItemCache) do
            Utility.Print(v)
        end
        Utility.Print("If one or more items have been wrongly ignored, please report them to us.")
    elseif cmd == "debug" then
        local itemString = args or nil
        if itemString then
            local _, itemLink, _, _, _, _, _, _, _, _, _, itemClassId, itemSubClassId = C_Item_GetItemInfo(itemString)
            if itemLink then
                local itemId = string_match(itemLink, "item:([%d]+)")
                if itemId then
                    itemId = tonumber(itemId)

                    local texts = Engine.ScanTooltip(itemLink)
                    if Utility.TableCount(texts) <= 0 then
                        Utility.Print("Item " .. itemString .. ": ScanTooltip failed, please retry.")
                        return
                    end

                    local itemData = self:MakeNewItemData(itemId, itemClassId, itemSubClassId)
                    itemData = Engine.ParseTexts(texts, itemData)
                    itemData.isRestricted = Engine.CheckRestriction(itemId)
                    self:PrintItemData(itemString, itemData)

                    Utility.Debug(itemData)
                end
            end
        else
            Utility.Print("Invalid argument")
        end
    elseif cmd == "bests" then
        Utility.Print("Best item ids:")
        for k,v in pairs(Core:BestsBeautifier()) do
            Utility.Print("bests."  .. k .. "=" .. v)
        end
    elseif cmd == "availables" then
        Utility.Print("Available items ids:")
        for k1, v1 in pairs(Core:AvailableItemsBeautifier()) do
            Utility.Print("Category: "  .. k1)
            for k2, v2 in pairs(v1) do
                local item = v2
                Utility.Print("- Id: "  .. item.itemId .. ", Value: " .. item.value .. ", stack size: " .. item.itemCount)
            end
        end
    else
        Utility.Print("Usage:")
        Utility.Print("/buffet combat [0, 1]: 1 to enable, 0 to disable")
        Utility.Print("/buffet clear: clear all caches")
        Utility.Print("/buffet delay [<number>]: show or set next scan delay in seconds (default is 1.2)")
        Utility.Print("/buffet info <itemLink>: display info about <itemLink> (if item is in cache)")
        Utility.Print("/buffet scan: perform a manual scan of your bags")
        Utility.Print(" ")
        Utility.Print("/buffet ignore-add <itemLink>: add item to ignore list")
        Utility.Print("/buffet ignore-remove <itemLink>: remove item from ignore list")
        Utility.Print("/buffet ignore-list: list all ignored items")
        Utility.Print("/buffet ignore-clear: clear the ignore list")
        Utility.Print(" ")
        Utility.Print("/buffet session-ignored: list all items automatically ignored from scan (session cached)")
        Utility.Print("/buffet debug <itemLink>: scan and display info about <itemLink> (bypass caches)")
        Utility.Print(" ")
        Utility.Print("/buffet bests: show current best item ids")
        Utility.Print("/buffet availables: show all currently available items ids")
    end
end

function Core:PrintItemData(itemString, itemData)
    Utility.Print("Item " .. itemString .. ":")
    Utility.Print("- Is health: " .. Utility.BoolToStr(itemData.isHealth))
    Utility.Print("- Is mana: " .. Utility.BoolToStr(itemData.isMana))
    Utility.Print("- Is well fed: " .. Utility.BoolToStr(itemData.isWellFed))
    Utility.Print("- Is conjured: " .. Utility.BoolToStr(itemData.isConjured))
    Utility.Print("- Is percent: " .. Utility.BoolToStr(itemData.isPct))
    if Locales.KeyWords.FoodAndDrink then
        Utility.Print("- Is food and drink: " .. Utility.BoolToStr(itemData.isFoodAndDrink))
    end
    Utility.Print("- Is potion: " .. Utility.BoolToStr(itemData.isPotion))
    Utility.Print("- Is toxic potion: " .. Utility.BoolToStr(itemData.isToxicPotion))
    Utility.Print("- Is bandage: " .. Utility.BoolToStr(itemData.isBandage))
    Utility.Print("- Is over time: " .. Utility.BoolToStr(itemData.isOverTime))
    Utility.Print("- Is restricted: ", Utility.BoolToStr(itemData.isRestricted))

    local overtimeTotalHealth = ""
    local overtimeTotalMana = ""
    if itemData.isOverTime and itemData.overTime and (itemData.overTime > 0) then
        if itemData.isPct then
            overtimeTotalHealth = string_format(" per second over %d second for a total of %d%% (%g hp)", itemData.overTime, itemData.overTime * itemData.health * 100, itemData.overTime * itemData.health * Core.playerHealth)
            overtimeTotalMana   = string_format(" per second over %d second for a total of %d%% (%g mp)", itemData.overTime, itemData.overTime * itemData.mana * 100, itemData.overTime * itemData.mana * Core.playerMana)
        else
            overtimeTotalHealth = string_format(" per second over %d second for a total of %g", itemData.overTime, itemData.overTime * itemData.health)
            overtimeTotalMana = string_format(" per second over %d second for a total of %g", itemData.overTime, itemData.overTime * itemData.mana)
        end
    end
    if itemData.isPct then
        Utility.Print(string_format("- health value: %d%% (%g hp)", itemData.health * 100, itemData.health * Core.playerHealth) .. overtimeTotalHealth)
        Utility.Print(string_format("- mana value: %d%% (%g mp)", itemData.mana * 100, itemData.mana * Core.playerMana) .. overtimeTotalMana)
    else
        Utility.Print(string_format("- health value: %g", itemData.health) .. overtimeTotalHealth)
        Utility.Print(string_format("- mana value: %g", itemData.mana) .. overtimeTotalMana)
    end
    Utility.Print("- itemClassId: " .. itemData.itemClassId)
    Utility.Print("- itemSubClassId: " .. itemData.itemSubClassId)
end

Buffet:RegisterEvent("ADDON_LOADED")

SLASH_BUFFET1 = "/buffet"
SlashCmdList["BUFFET"] = function(message, editbox)
    Core:SlashHandler(message, editbox)
end

-- Export
ns.Core = Core
