----------------------
--      Locals      --
----------------------

local addonName, ns = ...
Buffet_Version = GetAddOnMetadata(addonName, 'Version');

local defaults = { macroHP = "#showtooltip\n%MACRO%", macroMP = "#showtooltip\n%MACRO%", combat = true }
local firstRun = true
local dirty = false
local bests = ns.bests
local buffetTooltipFromTemplate = nil
local nextScan = 0
local nextScanDelay = 1.2
local tooltipCache = {}
local scanAttempt = {}
local itemCache = {}
local stats = {}
local IsClassic = false

local mylevel = 0
local myhealth = 0
local mymana = 0


-----------------------------
--   localize functions    --
-----------------------------
local match = string.match


-----------------------------
--      Event Handler      --
-----------------------------

Buffet = CreateFrame("frame")
Buffet:SetScript("OnEvent", function(self, event, ...)
    if self[event] then
        return self[event](self, event, ...)
    end
end)
Buffet:RegisterEvent("ADDON_LOADED")
function Buffet:Print(...)
    ChatFrame1:AddMessage(string.join(" ", "|cFF33FF99Buffet|r:", ...))
end
function Buffet:Debug(...)
    --@debug@
    -- [[
    local arg = {...}
    local t = ""
    for i, v in ipairs(arg) do
        if type(v) == "table" then
            for _, w in ipairs(v) do
                t = t .. ", " .. tostring(w)
            end
        else
            t = t .. " " .. tostring(v)
        end
    end
    ChatFrame1:AddMessage("|cFF33BB99Buffet|r:" .. t)
    --]]
    --@end-debug@
end

function Buffet:MyGetTime()
    return (debugprofilestop() / 1000)
end

function Buffet:BoolToStr(b)
    if b then
        return "Yes"
    end
    return "No"
end

function Buffet:SlashHandler(message, editbox)
    local _, _, cmd, args = string.find(message, "%s?(%w+)%s?(.*)")

    if cmd == "combat" then
        local combat = args or nil
        if combat ~= nil and combat ~= "" then
            combat = tonumber(combat)
            self.db.combat = (combat == 1)
            self:ScanDynamic()
        end
        if self.db.combat then
            self:Print("combat mode: enable")
        else
            self:Print("combat mode: disable")
        end
    elseif cmd == "stats" then
        self:Print("Session Statistics:")
        self:Print("- Functions called:")
        for k, v in pairs(stats.timers) do
            local item = v
            local avgTime = 0
            if v.count > 0 then
                avgTime = v.totalTime / v.count
            end
            self:Print(string.format("  - %s: %d time(s), total time: %.5fs, average time: %.5fs", k, v.count, v.totalTime, avgTime))
        end
        self:Print("- Events raised:")
        for k, v in pairs(stats.events) do
            self:Print(string.format("  - %s: %d time(s)", k, v))
        end
        self:Print("- Caches size:")
        self:Print(string.format("  - %d item(s) cached", self:TableCount(itemCache)))
        self:Print(string.format("  - %d tooltip(s) cached", self:TableCount(tooltipCache)))
    elseif cmd == "clear" then
        scanAttempt = {}
        tooltipCache = {}
        itemCache = {}
        self:Print("Caches cleared!")
        self:Print("Rescanning bags...")
        self:ScanDynamic()
    elseif cmd == "scan" then
        self:Print("Scanning bags...")
        self:ScanDynamic()
    elseif cmd == "delay" then
        local delay = args or nil
        if delay and delay ~= "" then
            delay = tonumber(delay)
            if type(delay) == "number" and delay >= 0.1 and delay <= 10 then
                self:Print("next scan delay set to", delay, "seconds")
                nextScanDelay = delay
            else
                self:Print("invalid value, delay must be a number between 0.1 and 10")
            end
        else
            self:Print("next scan delay current value is", nextScanDelay)
        end
    elseif cmd == "info" then
        local itemString = args or nil
        if itemString then
            local _, itemLink = GetItemInfo(itemString)
            if itemLink then
                local itemId = match(itemLink, "item:([%d]+)")
                if itemId then
                    itemId = tonumber(itemId)
                    if itemCache[itemId] then
                        local data = itemCache[itemId]
                        self:Print("Item " .. itemString .. ":")
                        self:Print("- Is health: " .. self:BoolToStr(data.isHealth))
                        self:Print("- Is mana: " .. self:BoolToStr(data.isMana))
                        self:Print("- Is well fed: " .. self:BoolToStr(data.isWellFed))
                        self:Print("- Is conjured: " .. self:BoolToStr(data.isConjured))
                        self:Print("- Is percent: " .. self:BoolToStr(data.isPct))
                        self:Print("- Is potion: " .. self:BoolToStr(data.isPotion))
                        self:Print("- Is bandage: " .. self:BoolToStr(data.isBandage))
                        if data.isPct then
                            self:Print(string.format("- health value: %d", data.health * 100))
                            self:Print(string.format("- mana value: %d", data.mana * 100))
                        else
                            self:Print(string.format("- health value: %d", data.health))
                            self:Print(string.format("- mana value: %d", data.mana))
                        end
                    else
                        self:Print("Item " .. itemString .. ": Not in cache")
                    end
                end
            end
        else
            self:Print("Invalid argument")
        end
    elseif cmd == "debug" then
        local itemString = args or nil
        if itemString then
            local _, itemLink, _, itemLevel, _, _, _, _, _, _, _, itemClassId, itemSubClassId = GetItemInfo(itemString)
            if itemLink then
                local itemId = match(itemLink, "item:([%d]+)")
                if itemId then
                    itemId = tonumber(itemId)

                    local texts, cached, failedAttempt = self:ScanTooltip(itemLink, itemId, itemLevel)
                    if failedAttempt or not cached then
                        self:Print("Item " .. itemString .. ": ScanTooltip failed")
                        return
                    end

                    local isHealth, isMana, isConjured, isWellFed, health, mana, isPct, isPotion, isBandage = self:ParseTexts(texts, itemClassId, itemSubClassId)

                    self:Print("Item " .. itemString .. ":")
                    self:Print("- Is health: " .. self:BoolToStr(isHealth))
                    self:Print("- Is mana: " .. self:BoolToStr(isMana))
                    self:Print("- Is well fed: " .. self:BoolToStr(isWellFed))
                    self:Print("- Is conjured: " .. self:BoolToStr(isConjured))
                    self:Print("- Is percent: " .. self:BoolToStr(isPct))
                    self:Print("- Is potion: " .. self:BoolToStr(isPotion))
                    self:Print("- Is bandage: " .. self:BoolToStr(isBandage))
                    if isPct then
                        self:Print(string.format("- health value: %d", health * 100))
                        self:Print(string.format("- mana value: %d", mana * 100))
                    else
                        self:Print(string.format("- health value: %d", health))
                        self:Print(string.format("- mana value: %d", mana))
                    end
                end
            end
        else
            self:Print("Invalid argument")
        end
    else
        self:Print("Usage:")
        self:Print("/buffet combat [0, 1]: 1 to enable, 0 to disable")
        self:Print("/buffet clear: clear all caches")
        self:Print("/buffet delay [<number>]: show or set next scan delay in seconds (default is 1.2)")
        self:Print("/buffet info <itemLink>: display info about <itemLink> (if item is in cache)")
        self:Print("/buffet scan: perform a manual scan of your bags")
        self:Print("/buffet stats: show some internal statistics")
        self:Print("/buffet debug <itemLink>: scan and display info about <itemLink> (bypass caches)")
    end
end
SLASH_BUFFET1 = "/buffet"
SlashCmdList["BUFFET"] = function(message, editbox)
    Buffet:SlashHandler(message, editbox)
end

function Buffet:ADDON_LOADED(event, addon)
    if addon:lower() ~= "buffet" then
        return
    end
    self:UnregisterEvent("ADDON_LOADED")

    -- load saved variables
    BuffetItemDB = BuffetItemDB or {}
    BuffetDB = setmetatable(BuffetDB or {}, { __index = defaults })
    self.db = BuffetDB

    local _, build, _, interfaceVersion = GetBuildInfo()
    local currBuild, prevBuild, buffetVersion = tonumber(build), BuffetItemDB.build, BuffetItemDB.version

    -- load items cache only if we are running the same build (client and addon)
    if prevBuild and (prevBuild == currBuild) and buffetVersion and (buffetVersion == Buffet_Version) then
        itemCache = BuffetItemDB.itemCache or {}
    else
        self:Print("Cache has been cleared due to version update.")
    end

    if interfaceVersion < 80000 then
        IsClassic = true
        self:Debug("Classic mode enabled")
    end

    nextScanDelay = BuffetItemDB.nextScanDelay or nextScanDelay

    -- clean saved variables
    BuffetItemDB = {}
    BuffetItemDB.itemCache = itemCache
    BuffetItemDB.build = currBuild
    BuffetItemDB.nextScanDelay = nextScanDelay
    BuffetItemDB.version = Buffet_Version

    stats.events = {}
    stats.timers = {}

    self.ADDON_LOADED = nil

    if IsLoggedIn() then
        self:PLAYER_LOGIN()
    else
        self:RegisterEvent("PLAYER_LOGIN")
    end
end

function Buffet:PLAYER_LOGIN()
    self:UnregisterEvent("PLAYER_LOGIN")

    stats.events["PLAYER_REGEN_ENABLED"] = 0
    stats.events["PLAYER_LEVEL_UP"] = 0
    stats.events["BAG_UPDATE_DELAYED"] = 0
    stats.events["UNIT_MAXHEALTH"] = 0
    stats.events["UNIT_MAXPOWER"] = 0
    stats.events["ZONE_CHANGED"] = 0

    stats.timers["ScanTooltip"] = { totalTime = 0, count = 0 }
    stats.timers["QueueScan"] = { totalTime = 0, count = 0 }
    stats.timers["ScanDynamic"] = { totalTime = 0, count = 0 }
    stats.timers["ParseTexts"] = { totalTime = 0, count = 0 }
    stats.timers["UpdateCallback"] = { totalTime = 0, count = 0 }

    self:RegisterEvent("PLAYER_LOGOUT")

    self:RegisterEvent("PLAYER_REGEN_ENABLED")
    self:RegisterEvent("PLAYER_LEVEL_UP")
    self:RegisterEvent("BAG_UPDATE_DELAYED")
    self:RegisterEvent("UNIT_MAXHEALTH")
    self:RegisterEvent("UNIT_MAXPOWER")

    --if not IsClassic then
        self:RegisterEvent("ZONE_CHANGED")
    --end

    self.PLAYER_LOGIN = nil

    mylevel = UnitLevel("player")
    myhealth = UnitHealthMax("player")
    mymana = UnitPowerMax("player")

    self:EnableDelayedScan()
    -- dirty = true
end

function Buffet:PLAYER_LOGOUT()
    for i, v in pairs(defaults) do
        if self.db[i] == v then
            self.db[i] = nil
        end
    end
    -- save itemCache per account
    BuffetItemDB.itemCache = itemCache
    BuffetItemDB.nextScanDelay = nextScanDelay
end

function Buffet:PLAYER_REGEN_ENABLED()
    stats.events["PLAYER_REGEN_ENABLED"] = stats.events["PLAYER_REGEN_ENABLED"] + 1
    if dirty then
        self:EnableDelayedScan()
    end
end

function Buffet:ZONE_CHANGED()
    stats.events["ZONE_CHANGED"] = stats.events["ZONE_CHANGED"] + 1
    self:QueueScan()
end

function Buffet:BAG_UPDATE_DELAYED()
    stats.events["BAG_UPDATE_DELAYED"] = stats.events["BAG_UPDATE_DELAYED"] + 1
    self:QueueScan()
end

function Buffet:PLAYER_LEVEL_UP(event, arg1)
    stats.events["PLAYER_LEVEL_UP"] = stats.events["PLAYER_LEVEL_UP"] + 1
    mylevel = arg1
    self:QueueScan()
end

function Buffet:UNIT_MAXHEALTH(event, arg1)
    if arg1 == "player" then
        stats.events["UNIT_MAXHEALTH"] = stats.events["UNIT_MAXHEALTH"] + 1
        myhealth = UnitHealthMax("player")
        self:QueueScan()
    end
end

function Buffet:UNIT_MAXPOWER(event, arg1, arg2)
    if (arg1 == "player") and (arg2 == "MANA") then
        stats.events["UNIT_MAXPOWER"] = stats.events["UNIT_MAXPOWER"] + 1
        mymana = UnitPowerMax("player")
        self:QueueScan()
    end
end

function Buffet:StatsTimerUpdate(key, t)
    stats.timers[key].count = stats.timers[key].count + 1
    local t2 = self:MyGetTime()
    stats.timers[key].totalTime = stats.timers[key].totalTime + (t2 - t)
end

function Buffet:QueueScan()
    local t = self:MyGetTime()
    if InCombatLockdown() then
        dirty = true -- try when out of combat (regen event)
    else
        self:EnableDelayedScan()
    end
    self:StatsTimerUpdate("QueueScan", t)
end

function Buffet:UpdateCallback(...)
    local t = self:MyGetTime()
    if nextScan > 0 then
        if nextScan <= t then
            if not InCombatLockdown() then
                self:DisableDelayedScan()
                self:ScanDynamic()
            end
        end
    end
    self:StatsTimerUpdate("UpdateCallback", t)
end

function Buffet:EnableDelayedScan()
    if nextScan == 0 then
        -- enable it only once
        self:SetScript("OnUpdate", self.UpdateCallback)
    end
    -- extend delay on consecutive calls
    nextScan = self:MyGetTime() + nextScanDelay
end

function Buffet:DisableDelayedScan()
    nextScan = 0
    self:SetScript("OnUpdate", nil)
end

function Buffet:TableCount(t)
    local c = 0
    if t then
        for v in pairs(t) do
            c = c + 1
        end
    end
    return c
end

function Buffet:GetTooltip()
    local tooltip = buffetTooltipFromTemplate or CreateFrame("GameToolTip", "buffetTooltipFromTemplate", nil, "GameTooltipTemplate")
    tooltip:SetOwner(WorldFrame, "ANCHOR_NONE")
    tooltip:ClearLines()
    return tooltip
end

function Buffet:ScanTooltip(itemLink, itemId, itemLevel)
    local t = self:MyGetTime()
    local cached = false
    local failedAttempt = false

    if tooltipCache[itemId] then
        cached = true
        self:StatsTimerUpdate("ScanTooltip", t)
        return tooltipCache[itemId], cached, false
    end

    local texts = {}
    local tooltip = self:GetTooltip()
    tooltip:SetHyperlink(itemLink)

    local isHealthItem = false
    local isManaItem = false
    local isConjuredItem = false

    -- [[
    local lineCount = 1
    for i = 2, tooltip:NumLines() do
        local text = _G["buffetTooltipFromTemplateTextLeft" .. i]:GetText() or ""
        text = self:Trim(text)
        if text ~= "" then
            texts[lineCount] = text
            lineCount = lineCount + 1
            if self:StringContains(text:lower(), KeyWords.Health:lower()) then
                isHealthItem = true
            end
            if self:StringContains(text:lower(), KeyWords.Mana:lower()) then
                isManaItem = true
            end
            if self:StringContains(text:lower(), KeyWords.ConjuredItem:lower()) then
                isConjuredItem = true
            end
        end
    end
    tooltip:Hide()
    --]]

    --[[
    -- not working :(
    for i=1,select("#",tooltip:GetRegions()) do
        local region=select(i,tooltip:GetRegions())
        if region and region:GetObjectType()=="FontString" and region:GetText() then
            local text = region:GetText()
            texts[i] = text
        end
    end
    --]]

    -- sometimes tooltips are not properly generated on first pass, all interesting items should have at least 3 lines, 4 for conjured items
    local neededLines = 3
    if isConjuredItem then
        neededLines = 4
    end
    -- except low level item which can have only 2 lines..
    if itemLevel < 10 then
        neededLines = neededLines - 1
    end

    neededLines = neededLines - 1

    --local l = self:TableCount(texts)
    if (lineCount >= neededLines) and (isHealthItem or isManaItem) then
        tooltipCache[itemId] = texts
        scanAttempt[itemId] = 0
        cached = true
    else
        if scanAttempt[itemId] then
            -- try to scan tooltip only 5 times
            if scanAttempt[itemId] < 5 then
                failedAttempt = true
                scanAttempt[itemId] = scanAttempt[itemId] + 1
            else
                tooltipCache[itemId] = texts
                scanAttempt[itemId] = 0
                cached = true
            end
        else
            scanAttempt[itemId] = 1
            failedAttempt = true
        end
    end

    self:StatsTimerUpdate("ScanTooltip", t)
    return texts, cached, failedAttempt
end

function Buffet:IsValidItemClass(itemClassId)
    if IsClassic then
        for k, v in pairs(Classic_ItemClasses) do
            if itemClassId == v then
                return true
            end
        end
    else
        return (itemClassId == ItemClasses.Consumable) or (itemClassId == ItemClasses.Miscellaneous)
    end
    return false
end

function Buffet:IsValidItemSubClass(itemClassId, itemSubClassId)
    if IsClassic then
        for k, v in pairs(Classic_ItemSubClasses) do
            if itemSubClassId == v then
                return true
            end
        end
    else
        if itemClassId == ItemClasses.Consumable then
            for k, v in pairs(ItemConsumableSubClasses) do
                if itemSubClassId == v then
                    return true
                end
            end
        elseif itemClassId == ItemClasses.Miscellaneous then
            for k, v in pairs(ItemMiscellaneousSubClasses) do
                if itemSubClassId == v then
                    return true
                end
            end
        end
    end
    return false
end

function Buffet:StringContains(s, needle)
    local f = s:find(needle, 1, true)
    if f == nil then
        return false
    end
    return true
end

function Buffet:SetBest(cat, id, value, stack)
    local best = bests[cat];
    if best and id then
        if (value > best.val) or ((value == best.val) and (best.stack > stack)) then
            best.val = value
            best.id = id
            best.stack = stack
        end
    end
end

function Buffet:ScanDynamic()
    local currentTime = self:MyGetTime()

    self:Debug("Scanning bags...")

    -- clear previous bests
    for k, t in pairs(bests) do
        t.val = -1
        t.id = nil
        t.stack = -1
    end

    local delayedScanRequired = false

    local itemIds = {}

    -- scan bags and build unique list of item ids
    for bag = 0, 4 do
        for slot = 1, GetContainerNumSlots(bag) do
            local _, _, _, _, _, _, _, _, _, itemId = GetContainerItemInfo(bag, slot)
            -- slot not empty
            if itemId then
                if not itemIds[itemId] then
                    -- get total count for this item id
                    itemIds[itemId] = GetItemCount(itemId)
                end
            end
        end
    end

    -- for each item id
    for k, v in pairs(itemIds) do
        local itemId, itemCount = k, v

        -- get item info
        local itemName, itemLink, _, itemLevel, itemMinLevel, _, _, _, _, _, _, itemClassId, itemSubClassId = GetItemInfo(itemId)
        --self:Debug("Debug:", itemId, itemName, itemClassId, itemSubClassId)

        -- ensure itemMinLevel is not nil
        itemMinLevel = itemMinLevel or 0

        -- treat only interesting items
        if itemLink and (itemMinLevel <= mylevel) and self:IsValidItemClass(itemClassId) and self:IsValidItemSubClass(itemClassId, itemSubClassId) then

            local isHealth = false
            local isMana = false
            local isConjured = false
            local isWellFed = false
            local isPct = false
            local isPotion = false
            local isBandage = false
            local isRestricted = false

            local health = 0
            local mana = 0

            local itemFoundInCache = false

            -- check cache for item
            if itemCache[itemId] then
                isHealth = itemCache[itemId].isHealth
                isMana = itemCache[itemId].isMana
                isConjured = itemCache[itemId].isConjured
                isWellFed = itemCache[itemId].isWellFed
                isPct = itemCache[itemId].isPct
                isPotion = itemCache[itemId].isPotion
                isBandage = itemCache[itemId].isBandage
                health = itemCache[itemId].health
                mana = itemCache[itemId].mana

                local validHealth = not isHealth or (isHealth and (health and (health > 0)))
                local validMana   = not isMana   or (isMana   and (mana   and (mana   > 0)))
                itemFoundInCache = isWellFed or validHealth or validMana
            end

            -- if not found, scan and parse tooltip
            if not itemFoundInCache then
                -- parse tooltip values
                local texts, cached, failedAttempt = self:ScanTooltip(itemLink, itemId, itemLevel)
                if failedAttempt then
                    delayedScanRequired = true
                else
                    isHealth, isMana, isConjured, isWellFed, health, mana, isPct, isPotion, isBandage = self:ParseTexts(texts, itemClassId, itemSubClassId)

                    local canCacheHealth = not isHealth or (isHealth and (health and (health > 0)))
                    local canCacheMana   = not isMana   or (isMana   and (mana   and (mana   > 0)))

                    if cached and (isWellFed or canCacheHealth or canCacheMana) then
                        itemCache[itemId] = {}
                        itemCache[itemId].isHealth = isHealth
                        itemCache[itemId].isMana = isMana
                        itemCache[itemId].isConjured = isConjured
                        itemCache[itemId].isWellFed = isWellFed
                        itemCache[itemId].isPct = isPct
                        itemCache[itemId].isPotion = isPotion
                        itemCache[itemId].isBandage = isBandage
                        itemCache[itemId].health = health
                        itemCache[itemId].mana = mana
                    end
                end
            end

            -- check restricted items against rules
            if Restrictions[itemId] then
                if not isRestricted and Restrictions[itemId].inInstanceIds then
                    isRestricted = not self:IsPlayerInInstanceId(Restrictions[itemId].inInstanceIds)
                end
                if not isRestricted and Restrictions[itemId].inInstanceTypes then
                    isRestricted = not self:IsPlayerInInstanceType(Restrictions[itemId].inInstanceTypes)
                end
                if not isRestricted and Restrictions[itemId].inSubZones then
                    isRestricted = not self:IsPlayerInSubZoneName(Restrictions[itemId].inSubZones)
                end
            end

            -- set found values to best
            if not isRestricted and not isWellFed and ((health and (health > 0)) or (mana and (mana > 0))) then

                -- update pct values
                if isPct then
                    if (health and (health > 0)) then
                        health = health * myhealth
                    end
                    if (mana and (mana > 0)) then
                        mana = mana * mymana
                    end
                end

                local cat = nil
                local fnd = false
                local pot = false
                local bdg = false
                local oth = false

                if IsClassic then
                    fnd = not isPotion and not isBandage
                    pot = isPotion
                    bdg = isBandage
                    oth = isPotion and not isBandage
                else
                    if itemClassId == ItemClasses.Consumable then
                        fnd = itemSubClassId == ItemConsumableSubClasses.FoodAndDrink
                        pot = itemSubClassId == ItemConsumableSubClasses.Potion
                        bdg = itemSubClassId == ItemConsumableSubClasses.Bandage
                        oth = itemSubClassId == ItemConsumableSubClasses.Other
                    elseif itemClassId == ItemClasses.Miscellaneous then
                        fnd = itemSubClassId == ItemMiscellaneousSubClasses.Reagent
                        pot = false
                        bdg = false
                        oth = false
                    end
                end

                if fnd then
                    if isHealth then
                        if isConjured then
                            cat = ns.categories.percfood
                        else
                            cat = ns.categories.food
                        end
                        self:SetBest(cat, itemId, health, itemCount)
                    end
                    if isMana then
                        if isConjured then
                            cat = ns.categories.percwater
                        else
                            cat = ns.categories.water
                        end
                        self:SetBest(cat, itemId, mana, itemCount)
                    end
                elseif pot then
                    if isHealth then
                        cat = ns.categories.hppot
                        self:SetBest(cat, itemId, health, itemCount)
                    end
                    if isMana then
                        cat = ns.categories.mppot
                        self:SetBest(cat, itemId, mana, itemCount)
                    end
                elseif bdg then
                    if isHealth then
                        cat = ns.categories.bandage
                        self:SetBest(cat, itemId, health, itemCount)
                    end
                elseif oth then
                    -- health stone / mana gem
                    if isConjured then
                        if isHealth then
                            cat = ns.categories.healthstone
                            self:SetBest(cat, itemId, health, itemCount)
                        end
                        if isMana then
                            cat = ns.categories.manastone
                            self:SetBest(cat, itemId, health, itemCount)
                        end
                    end
                end
            end
        end
    end

    local food = bests.percfood.id or bests.food.id or bests.healthstone.id or bests.hppot.id
    local water = bests.percwater.id or bests.water.id or bests.managem.id or bests.mppot.id

    self:Edit("AutoHP", self.db.macroHP, food, bests.healthstone.id or bests.hppot.id, bests.bandage.id)
    self:Edit("AutoMP", self.db.macroMP, water, bests.managem.id or bests.mppot.id)

    -- if we didn't found any food or water, and it is the first run, queue a delayed scan
    if (not food and not water) and firstRun then
        firstRun = false
        delayedScanRequired = true
    end

    dirty = false

    if delayedScanRequired then
        self:EnableDelayedScan()
    end

    self:StatsTimerUpdate("ScanDynamic", currentTime)
end

function Buffet:StripThousandSeparator(text)
    if type(ThousandSeparator) == "string" then
        text = text:gsub(ThousandSeparator, "")
    elseif type(ThousandSeparator) == "table" then
        for i, v in ipairs(ThousandSeparator) do
            text = text:gsub(v, "")
        end
    end
    return text
end

function Buffet:ReplaceFakeSpace(text)
    local t = ""
    t = text:gsub(" ", " ") -- WTF Blizzard !
    return t
end

function Buffet:ParseTexts(texts, itemClassId, itemSubClassId)
    local t = self:MyGetTime()

    local isBandage = false
    local isPotion = false
    local isHealth = false
    local isMana = false
    local isConjured = false
    local isWellFed = false
    local isPct = false
    local isOverTime = false

    local health = 0
    local mana = 0
    local overTime = 0

    for i, v in ipairs(texts) do
        local text = string.lower(v);

        -- Conjured item
        if self:StringContains(text, KeyWords.ConjuredItem:lower()) then
            isConjured = true
        end

        -- Bandage for classic
        if IsClassic and self:StringContains(text, Classic_KeyWords.Bandage:lower()) then
            isBandage = true
        elseif not IsClassic and itemClassId == ItemClasses.Consumable and itemSubClassId == ItemConsumableSubClasses.Bandage then
            isBandage = true
        end

        -- well fed
        if self:StringContains(text, KeyWords.WellFed:lower()) then
            isWellFed = true
        end

        -- OverTime
        if self:StringContains(text, KeyWords.OverTime:lower()) then
            isOverTime = true
        end

        -- Usable item
        local usable = false
        if IsClassic and  Classic_KeyWords.Use then
            usable = self:StringContains(text, Classic_KeyWords.Use:lower())
        else
            usable = self:StringContains(text, KeyWords.Use:lower())
        end

        if usable then
            if IsClassic then
                 isHealth = isBandage or self:StringContains(text, KeyWords.Health:lower())
            else
                if isBandage then
                    isHealth = self:StringContains(text, KeyWords.Damage:lower())
                else
                    isHealth = self:StringContains(text, KeyWords.Health:lower())
                end
            end
            isMana = self:StringContains(text, KeyWords.Mana:lower())

            if isHealth or isMana then
                -- FU Blizzard
                text = self:ReplaceFakeSpace(text)
            end

            if isHealth then
                if IsClassic then
                    local value, v1, v2 = nil, nil, nil
                    if isBandage then
                        v1, v2 = match(text, Classic_Patterns.Bandage)
                        if GetLocale() == "deDE" or "zhCN" then
                            value = v2
                        else
                            value = v1
                        end
                    else
                        v1, v2 = match(text, Classic_Patterns.Food)
                        if GetLocale() == "deDE" or "zhCN" then
                            value = v2
                        else
                            value = v1
                        end
                        if not value then
                            -- check for potion
                            v1, v2 = match(text, Classic_Patterns.HealthPotion)
                            if v1 and v2 then
                                isPotion = true
                                v1 = self:StripThousandSeparator(v1)
                                v2 = self:StripThousandSeparator(v2)
                                value = (tonumber(v1) + tonumber(v2)) / 2
                            end
                        end
                    end
                    if value then
                        if type(value) ~= "number" then
                            value = self:StripThousandSeparator(value)
                            health = tonumber(value)
                        else
                            health = value
                        end
                    end
                else
                    if isBandage then
                        if self:StringContains(text, KeyWords.Heals:lower()) then
                            local value = match(text, Patterns.FlatDamage);
                            if value then
                                value = self:StripThousandSeparator(value)
                                health = tonumber(value)
                            end
                        end
                    else
                        if self:StringContains(text, KeyWords.Restores:lower()) then
                            local value = match(text, Patterns.PctHealth);
                            if value then
                                isPct = true
                                value = self:StripThousandSeparator(value)
                                health = (tonumber(value) / 100) -- * myhealth;
                            else
                                value = match(text, Patterns.FlatHealth);
                                if value then
                                    value = self:StripThousandSeparator(value)
                                    health = tonumber(value)
                                end
                            end
                            if health and (health > 0) and isOverTime then
                                local overTime = match(text, Patterns.OverTime)
                                if overTime then
                                    health = health * tonumber(overTime)
                                end
                            end
                        end
                    end
                end
            end

            if isMana then
                if IsClassic then
                    local value, v1, v2 = nil, nil, nil
                    v1, v2 = match(text, Classic_Patterns.Drink)
                    if GetLocale() == "deDE" or "zhCN" then
                        value = v2
                    else
                        value = v1
                    end
                    if not value then
                        -- check for potion
                        v1, v2 = match(text, Classic_Patterns.ManaPotion)
                        if v1 and v2 then
                            isPotion = true
                            v1 = self:StripThousandSeparator(v1)
                            v2 = self:StripThousandSeparator(v2)
                            value = (tonumber(v1) + tonumber(v2)) / 2
                        end
                    end
                    if value then
                        if type(value) ~= "number" then
                            value = self:StripThousandSeparator(value)
                            mana = tonumber(value)
                        else
                            mana = value
                        end
                    end
                else
                    if self:StringContains(text, KeyWords.Restores:lower()) then
                        local offsetMana = 1;
                        if isHealth then
                            offsetMana = text:find(KeyWords.Health)
                        end

                        local value = match(text, Patterns.PctMana, offsetMana)
                        if value then
                            isPct = true
                            value = self:StripThousandSeparator(value)
                            mana = (tonumber(value) / 100) -- * mymana;
                        else
                            value = match(text, Patterns.FlatMana, offsetMana);
                            if value then
                                value = self:StripThousandSeparator(value)
                                mana = tonumber(value)
                            end
                        end

                        -- in some cases there is only one value for health and mana, so we need to try without the offsetMana
                        if not value then
                            value = match(text, Patterns.PctMana);
                            if value then
                                isPct = true
                                value = self:StripThousandSeparator(value)
                                mana = (tonumber(value) / 100) -- * mymana;
                            else
                                value = match(text, Patterns.FlatMana);
                                if value then
                                    value = self:StripThousandSeparator(value)
                                    mana = tonumber(value)
                                end
                            end
                        end

                        if mana and (mana > 0) and isOverTime then
                            local overTime = match(text, Patterns.OverTime)
                            if overTime then
                                mana = mana * tonumber(overTime)
                            end
                        end
                    end
                end
            end
        end
    end

    self:StatsTimerUpdate("ParseTexts", t)

    return isHealth, isMana, isConjured, isWellFed, health, mana, isPct, isPotion, isBandage
end

function Buffet:IsPlayerInInstanceId(ids)
    local _,instanceType,_,_,_,_,_,instanceId = GetInstanceInfo()
    if instanceId then
        for _,v in pairs(ids) do
            if v == instanceId then
                return true
            end
        end
    end
    return false
end

function Buffet:IsPlayerInInstanceType(types)
    local _,instanceType, diffId = GetInstanceInfo()
    instanceType = instanceType or "none"
    for _,v in pairs(types) do
        if (v == "none" and diffId == 0 and instanceType ~= "pvp" and instanceType ~= "arena") then
            return true
        end
        if (v == instanceType) then
            return true
        end
    end
    return false
end

function Buffet:IsPlayerInZoneId(ids)
    local mapId = C_Map.GetBestMapForUnit("player");
    if mapId then
        repeat
            for v in ids do
                if v == mapId then
                    return true
                end
            end
            local mapInfo = C_Map.GetMapInfo(mapId);
            mapId = mapInfo and mapInfo.parentMapID or 0;
        until mapId == 0;
    end
    return false
end

function Buffet:IsPlayerInSubZoneName(names)
    local currentSubZone = string.lower(GetSubZoneText())
    if currentSubZone ~= "" then
        local babbleSubZone = LibStub("LibBabble-SubZone-3.0"):GetUnstrictLookupTable();
        for k,v in pairs(names) do
            local subZone = babbleSubZone[v] -- get locale subzone name from LibBabble
            if subZone and (subZone:lower() == currentSubZone) then
                return true
            end
        end
    end
    return false
end

function Buffet:Edit(name, substring, food, pot, mod)
    local macroid = GetMacroIndexByName(name)
    if not macroid then
        return
    end

    local body = "/use "
    if mod then
        body = body .. "[mod,target=player] item:" .. mod .. "; "
    end
    if self.db.combat and pot then
        body = body .. "[combat] item:" .. pot .. "; "
    end
    body = body .. "item:" .. (food or "6948")

    EditMacro(macroid, name, "INV_Misc_QuestionMark", substring:gsub("%%MACRO%%", body), 1)
end

function Buffet:Trim(s)
    return match(s,'^()%s*$') and '' or match(s,'^%s*(.*%S)')
end
