local addonName, ns = ...

-- Imports
local Utility = ns.Utility
local Const = ns.Const
local Engine = ns.Engine
local Locales = ns.Locales

-- Localize functions
local string_match = string.match
local string_find = string.find
local string_format = string.format

-- Local namespace
local Core = {}

-- Some init
Core.nextScan = 0
Core.nextScanTimer = nil
Core.bests = {}
Core.scanAttempt = {}
Core.firstRun = true
Core.scanning = false
Core.itemCache = {}
Core.ignoredItemCache = {}
Core.macros = {}

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

    Core.Version = GetAddOnMetadata(addonName, 'Version');

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

    Core.stats = {}
    Core.stats.events = {}
    Core.stats.timers = {}

    Core:ResetBest()

    self.ADDON_LOADED = nil

    if IsLoggedIn() then
        self:PLAYER_LOGIN()
    else
        self:RegisterEvent("PLAYER_LOGIN")
    end
end

function Buffet:PLAYER_LOGIN()
    self:UnregisterEvent("PLAYER_LOGIN")

    Core.stats.events["PLAYER_REGEN_ENABLED"] = 0
    Core.stats.events["PLAYER_LEVEL_UP"] = 0
    Core.stats.events["BAG_UPDATE_DELAYED"] = 0
    Core.stats.events["UNIT_MAXHEALTH"] = 0
    Core.stats.events["UNIT_MAXPOWER"] = 0
    Core.stats.events["ZONE_CHANGED"] = 0

    --Core.stats.timers["ParseTexts"] = { totalTime = 0, count = 0 }
    --Core.stats.timers["ScanTooltip"] = { totalTime = 0, count = 0 }
    Core.stats.timers["QueueScan"] = { totalTime = 0, count = 0 }
    Core.stats.timers["Scan"] = { totalTime = 0, count = 0 }
    Core.stats.timers["UpdateCallback"] = { totalTime = 0, count = 0 }

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

    Utility.Print("Buffet ", Core.Version, " Loaded!")

    if Utility.IsClassic then
        Utility.Debug("Classic mode enabled")
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
    for i, v in pairs(Core.db) do
        if not Const.DBdefaults[i] then
            Core.db[i] = nil
        end
    end

    -- Save BuffetItemDB
    BuffetItemDB.itemCache = Core.itemCache
    BuffetItemDB.nextScanDelay = Core.nextScanDelay
    for i, v in pairs(Const.ItemDBdefaults) do
        if BuffetItemDB[i] == v then
            BuffetItemDB[i] = nil
        end
    end
    for i, v in pairs(BuffetItemDB) do
        if not Const.ItemDBdefaults[i] then
            BuffetItemDB[i] = nil
        end
    end
end

function Buffet:PLAYER_REGEN_ENABLED()
    Core.stats.events["PLAYER_REGEN_ENABLED"] = Core.stats.events["PLAYER_REGEN_ENABLED"] + 1
    if Core.dirty then
        Core:EnableDelayedScan()
    end
end

function Buffet:ZONE_CHANGED()
    Core.stats.events["ZONE_CHANGED"] = Core.stats.events["ZONE_CHANGED"] + 1
    Core:QueueScan()
end
function Buffet:ZONE_CHANGED_NEW_AREA()
    Buffet:ZONE_CHANGED()
end

function Buffet:BAG_UPDATE_DELAYED()
    Core.stats.events["BAG_UPDATE_DELAYED"] = Core.stats.events["BAG_UPDATE_DELAYED"] + 1
    Core:QueueScan()
end

function Buffet:PLAYER_LEVEL_UP(event, arg1)
    Core.stats.events["PLAYER_LEVEL_UP"] = Core.stats.events["PLAYER_LEVEL_UP"] + 1
    Core.playerLevel = arg1
    Core:QueueScan()
end

function Buffet:UNIT_MAXHEALTH(event, arg1)
    if arg1 == "player" then
        Core.stats.events["UNIT_MAXHEALTH"] = Core.stats.events["UNIT_MAXHEALTH"] + 1
        Core.playerHealth = UnitHealthMax("player")
        Core:QueueScan()
    end
end

function Buffet:UNIT_MAXPOWER(event, arg1, arg2)
    if (arg1 == "player") and (arg2 == "MANA") then
        Core.stats.events["UNIT_MAXPOWER"] = Core.stats.events["UNIT_MAXPOWER"] + 1
        Core.playerMana = UnitPowerMax("player")
        Core:QueueScan()
    end
end

function Core:ResetBest()
    for _, v in pairs(Const.BestCategories) do
        Core.bests[v] = { val = -1, stack = -1, id = nil }
    end
end

function Core:QueueScan()
    local t = Utility.GetTime()
    if InCombatLockdown() then
        self.dirty = true -- try when out of combat (regen event)
    else
        self:EnableDelayedScan()
    end
    self:StatsTimerUpdate("QueueScan", t)
end

function Core:EnableDelayedScan()
    if self.nextScanTimer then
        self.nextScanTimer:Cancel()
    end
    -- restart timer each time we queue a scan
    self.nextScanTimer = C_Timer.NewTimer(Core.nextScanDelay, self.OnTimerCallback)
end

function Core:OnTimerCallback()
    local t = Utility.GetTime()
    Core.nextScanTimer = nil
    if InCombatLockdown() then
        Core.dirty = true
    else
        Core:Scan()
    end
    Core:StatsTimerUpdate("UpdateCallback", t)
end

function Core:Scan()
    if Core.scanning then
        return
    end
    local currentTime = Utility.GetTime()

    Core.scanning = true

    Utility.Debug("Scanning bags...")

    -- clear previous bests
    self:ResetBest()

    local delayedScanRequired = false
    local itemIds = {}

    -- scan bags and build unique list of item ids
    for bag = 0, 4 do
        for slot = 1, GetContainerNumSlots(bag) do
            local _, _, _, _, _, _, _, _, _, itemId = GetContainerItemInfo(bag, slot)
            -- slot not empty
            if itemId then
                if not Core.ignoredItemCache[itemId] then
                    if not itemIds[itemId] then
                        -- get total count for this item id
                        itemIds[itemId] = GetItemCount(itemId)
                    end
                end
            end
        end
    end

    -- for each item id
    for k, v in pairs(itemIds) do
        local itemId, itemCount = k, v

        -- get item info
        local itemName, itemLink, _, itemLevel, itemMinLevel, _, _, _, _, _, _, itemClassId, itemSubClassId = GetItemInfo(itemId)
        -- Utility.Debug("Debug:", itemId, itemName, itemClassId, itemSubClassId)

        -- ensure itemMinLevel is not nil
        itemMinLevel = itemMinLevel or 0

        -- treat only interesting items
        if itemLink and (itemMinLevel <= self.playerLevel) and (Engine.IsValidItemClasses(itemClassId, itemSubClassId)) then
            local itemData = self:MakeNewItemData(itemId, itemClassId, itemSubClassId)

            local itemFoundInCache = false

            -- check cache for item
            if Core.itemCache[itemId] then
                itemData = Core.itemCache[itemId]

                local validHealth = not itemData.isHealth or (itemData.isHealth and (itemData.health and itemData.health > 0))
                local validMana   = not itemData.isMana   or (itemData.isMana   and (itemData.mana   and itemData.mana   > 0))
                itemFoundInCache = itemData.isWellFed or validHealth or validMana
            end

            -- if not found, scan and parse tooltip
            if not itemFoundInCache then
                -- parse tooltip values
                local texts, failedAttempt = Engine.ScanTooltip(itemLink, itemMinLevel)

                if failedAttempt and (not Core.scanAttempt[itemId] or Core.scanAttempt[itemId] < 5) then
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

                        if itemData.isWellFed or validHealth or validMana then
                            Core.itemCache[itemId] = itemData
                            itemFoundInCache = true
                        else
                            if Core.scanAttempt[itemId] then
                                Core.scanAttempt[itemId] = Core.scanAttempt[itemId] + 1
                            else
                                Core.scanAttempt[itemId] = 1
                            end
                            -- Utility.Debug("Need rescan for: ", itemLink)
                            delayedScanRequired = true
                        end
                    end
                end
            end

            -- if item is usable
            if itemFoundInCache and not itemData.isWellFed and ((itemData.health and (itemData.health > 0)) or (itemData.mana and (itemData.mana > 0))) then
                -- Utility.Debug(itemName, itemData)

                local isRestricted = Engine.CheckRestriction(itemId)

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
                        for k, v in pairs(healthCats) do
                            self:SetBest(v, itemId, health, itemCount)
                        end
                    end
                    if manaCats then
                        for k, v in pairs(manaCats) do
                            self:SetBest(v, itemId, mana, itemCount)
                        end
                    end
                end
            end
        end
    end

    -- 12662 demonic rune, 20520 dark rune
    if itemIds[12662] and (itemIds[12662] > 0) and (50 <= self.playerLevel) then
        self:SetBest(Const.BestCategories.rune, 12662, 1200, itemIds[12662])
    end
    if itemIds[20520] and (itemIds[20520] > 0) and (55 <= self.playerLevel) then
        self:SetBest(Const.BestCategories.rune, 20520, 1199, itemIds[20520]) -- health set to 1199 to prioritize demonic rune over dark rune
    end

    --local food = Core.bests.percfood.id or Core.bests.food.id or Core.bests.healthstone.id or Core.bests.hppot.id
    --local water = Core.bests.percwater.id or Core.bests.water.id or Core.bests.managem.id or Core.bests.mppot.id
    local food = Core.bests.percfood.id or Core.bests.food.id
    local water = Core.bests.percwater.id or Core.bests.water.id

    --self:Edit("AutoHP", Core.db.macroHP, food, Core.bests.healthstone.id or Core.bests.hppot.id, Core.bests.bandage.id)
    --self:Edit("AutoMP", Core.db.macroMP, water, Core.bests.managem.id or Core.bests.mppot.id)

    self:EditDefault(Const.MacroNames.defaultHP, Core.db.macroHP, food, Core.bests.healthstone.id, Core.bests.hppot.id, Core.bests.bandage.id)
    self:EditDefault(Const.MacroNames.defaultMP, Core.db.macroMP, water, Core.bests.managem.id, Core.bests.mppot.id, Core.bests.rune.id)

    self:EditFoodOnly(Const.MacroNames.foodOnlyHP, Core.db.macroHP, food)
    self:EditFoodOnly(Const.MacroNames.drinkOnlyMP, Core.db.macroMP, water)

    self:EditConsumable(Const.MacroNames.consumableHP, Core.db.macroHP, Core.bests.healthstone.id, Core.bests.hppot.id, Core.bests.bandage.id)
    self:EditConsumable(Const.MacroNames.consumableMP, Core.db.macroMP, Core.bests.managem.id, Core.bests.mppot.id, Core.bests.rune.id)

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

    self:StatsTimerUpdate("Scan", currentTime)
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
    itemData.isBandage = false
    itemData.isRestricted = false
    itemData.isOverTime = false
    itemData.health = 0
    itemData.mana = 0
    itemData.overTime = 0
    itemData.itemClassId = itemClassId
    itemData.itemSubClassId = itemSubClassId
    return itemData
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

--    Utility.Debug("food: ", food)
--    Utility.Debug("conjured: ", conjured)
--    Utility.Debug("pot: ", pot)
--    Utility.Debug("mod: ", mod)

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

    -- Utility.Debug("default: ", cast)

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


function Core:SetBest(cat, id, value, stack)
    -- Utility.Debug("SetBest: ", cat, id, value, stack)
    local best = Core.bests[cat];
    if best and id then
        if (value > best.val) or ((value == best.val) and (best.stack > stack)) then
            best.val = value
            best.id = id
            best.stack = stack
        end
    end
end

function Core:SlashHandler(message, editbox)
    local _, _, cmd, args = string.find(message, "%s?(%w+)%s?(.*)")

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
    elseif cmd == "stats" then
        Utility.Print("Session Statistics:")
        Utility.Print("- Functions called:")
        for k, v in pairs(Core.stats.timers) do
            local item = v
            local avgTime = 0
            if v.count > 0 then
                avgTime = v.totalTime / v.count
            end
            Utility.Print(string_format("  - %s: %d time(s), total time: %.5fs, average time: %.5fs", k, v.count, v.totalTime, avgTime))
        end
        Utility.Print("- Events raised:")
        for k, v in pairs(Core.stats.events) do
            Utility.Print(string_format("  - %s: %d time(s)", k, v))
        end
        Utility.Print("- Caches size:")
        Utility.Print(string_format("  - %d item(s) cached", Utility.TableCount(Core.itemCache)))
    elseif cmd == "clear" then
        Core.scanAttempt = {}
        Core.itemCache = {}
        Core.ignoredItemCache = {}
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
    elseif cmd == "ignored" then
        Utility.Print("The following items have been ignored from scans:")
        for k,v in pairs(Core.ignoredItemCache) do
            Utility.Print(v)
        end
        Utility.Print("If one or more items have been wrongly ignored, please report them to us.")
    elseif cmd == "debug" then
        local itemString = args or nil
        if itemString then
            local _, itemLink, _, itemLevel, itemMinLevel, _, _, _, _, _, _, itemClassId, itemSubClassId = GetItemInfo(itemString)
            if itemLink then
                local itemId = string_match(itemLink, "item:([%d]+)")
                if itemId then
                    itemId = tonumber(itemId)

                    local texts, failedAttempt = Engine.ScanTooltip(itemLink, itemMinLevel)
                    if failedAttempt then
                        Utility.Print("Item " .. itemString .. ": ScanTooltip failed")
                        Utility.Debug(texts)
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
--@debug@
    elseif cmd == "showzone" then
        Utility.ShowPlayerZoneInfo()
--@end-debug@
    else
        Utility.Print("Usage:")
        Utility.Print("/buffet combat [0, 1]: 1 to enable, 0 to disable")
        Utility.Print("/buffet clear: clear all caches")
        Utility.Print("/buffet delay [<number>]: show or set next scan delay in seconds (default is 1.2)")
        Utility.Print("/buffet info <itemLink>: display info about <itemLink> (if item is in cache)")
        Utility.Print("/buffet scan: perform a manual scan of your bags")
        Utility.Print("/buffet ignored: list all items ignored from scan (session cached)")
        Utility.Print("/buffet stats: show some internal statistics")
        Utility.Print("/buffet debug <itemLink>: scan and display info about <itemLink> (bypass caches)")
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
    Utility.Print("- Is bandage: " .. Utility.BoolToStr(itemData.isBandage))
    Utility.Print("- Is over time: " .. Utility.BoolToStr(itemData.isOverTime))
    Utility.Print("- Is restricted: ", Utility.BoolToStr(itemData.isRestricted))

    local overtimeTotalHealth = ""
    local overtimeTotalMana = ""
    if itemData.isOverTime and itemData.overTime and (itemData.overTime > 0) then
        if itemData.isPct then
            overtimeTotalHealth = string_format(" per second over %d second for a total of %d%% (%d hp)", itemData.overTime, itemData.overTime * itemData.health * 100, itemData.overTime * itemData.health * Core.playerHealth)
            overtimeTotalMana   = string_format(" per second over %d second for a total of %d%% (%d mp)", itemData.overTime, itemData.overTime * itemData.mana * 100, itemData.overTime * itemData.mana * Core.playerMana)
        else
            overtimeTotalHealth = string_format(" per second over %d second for a total of %d", itemData.overTime, itemData.overTime * itemData.health)
            overtimeTotalMana = string_format(" per second over %d second for a total of %d", itemData.overTime, itemData.overTime * itemData.mana)
        end
    end
    if itemData.isPct then
        Utility.Print(string_format("- health value: %d%% (%d hp)", itemData.health * 100, itemData.health * Core.playerHealth) .. overtimeTotalHealth)
        Utility.Print(string_format("- mana value: %d%% (%d mp)", itemData.mana * 100, itemData.mana * Core.playerMana) .. overtimeTotalMana)
    else
        Utility.Print(string_format("- health value: %d", itemData.health) .. overtimeTotalHealth)
        Utility.Print(string_format("- mana value: %d", itemData.mana) .. overtimeTotalMana)
    end
    Utility.Print("- itemClassId: " .. itemData.itemClassId)
    Utility.Print("- itemSubClassId: " .. itemData.itemSubClassId)
end

function Core:StatsTimerUpdate(key, t)
    Core.stats.timers[key].count = Core.stats.timers[key].count + 1
    local t2 = Utility.GetTime()
    Core.stats.timers[key].totalTime = Core.stats.timers[key].totalTime + (t2 - t)
end

Buffet:RegisterEvent("ADDON_LOADED")

SLASH_BUFFET1 = "/buffet"
SlashCmdList["BUFFET"] = function(message, editbox)
    Core:SlashHandler(message, editbox)
end

-- Export
ns.Core = Core
