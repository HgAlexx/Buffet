local _, ns = ...

-- Imports
local Utility = ns.Utility
local Locales = ns.Locales

-- Local namespace
local Engine = ns.Engine or {}

local string_gsub = string.gsub
local string_match = string.match

function Engine.ScanTooltip(itemLink, itemLevel)
    local failedAttempt
    local texts = {}
    local tooltip = Utility.GetTooltip()
    tooltip:SetHyperlink(itemLink)

    local isConjured = false
    local lineCount = 0
    for i = 2, tooltip:NumLines() do
        local text = _G["buffetTooltipTextLeft" .. i]:GetText() or ""
        text = Utility.Trim(text)
        if text ~= "" then
            texts[lineCount] = text
            local lowerText = text:lower()
            lineCount = lineCount + 1
            if Utility.StringContains(lowerText, Locales.KeyWords.ConjuredItem:lower()) then
                isConjured = true
            end
        end
    end
    tooltip:Hide()

    -- sometimes tooltips are not properly generated on first pass, all interesting items should have at least 3 lines, 4 for conjured items
    local neededLines = 3
    if isConjured then
        neededLines = 4
    end
    -- except low level item which can have only 2 lines..
    if itemLevel and itemLevel < 10 then
        neededLines = neededLines - 1
    end

    -- for item name (skipped in loop above)
    neededLines = neededLines - 1

    if (lineCount >= neededLines) then
        failedAttempt = false
    else
        failedAttempt = true
    end

    return  texts, failedAttempt
end

function Engine.ParseTexts(texts, itemData)
    local itemDescription = ""
    local usable = false

    for i, v in pairs(texts) do
        local text = string.lower(v);

        -- Food and Drink
        if Locales.KeyWords.FoodAndDrink then
            if not itemData.isFoodAndDrink and Utility.StringContains(text, Locales.KeyWords.FoodAndDrink:lower()) then
                itemData.isFoodAndDrink = true
            end
        end

        -- Conjured item
        if not itemData.isConjured and Utility.StringContains(text, Locales.KeyWords.ConjuredItem:lower()) then
            itemData.isConjured = true
        end

        -- Bandage
        if not itemData.isBandage and Engine.CheckBandage(text, itemData.itemClassId, itemData.itemSubClassId) then
            itemData.isBandage = true
        end

        -- Potion
        if not itemData.isPotion and Engine.CheckPotion(text, itemData.itemClassId, itemData.itemSubClassId) then
            itemData.isPotion = true
        end

        -- well fed
        if not itemData.isWellFed then
            if type(Locales.KeyWords.WellFed) == "table" then
                for _, s in pairs(Locales.KeyWords.WellFed) do
                    if Utility.StringContains(text, s:lower()) then
                        itemData.isWellFed = true
                        break
                    end
                end
            elseif type(Locales.KeyWords.WellFed) == "string" then
                if Utility.StringContains(text, Locales.KeyWords.WellFed:lower()) then
                    itemData.isWellFed = true
                end
            end
        end

        -- OverTime
        if not itemData.isOverTime and Utility.StringContains(text, Locales.KeyWords.OverTime:lower()) then
            itemData.isOverTime = true
        end

        -- Usable item
        if not usable  and Engine.CheckUsable(text) then
            usable = true
        end

        -- if usable, we should be on the line with health/mana value
        if usable and itemDescription == "" then
            itemDescription = text
        end
    end

    if usable and itemDescription ~= "" then
        -- health
        itemData.isHealth = Engine.CheckHealth(itemDescription, itemData.isBandage)
        -- mana
        if Utility.StringContains(itemDescription, Locales.KeyWords.Mana:lower()) then
            itemData.isMana = true
        end

        if itemData.isHealth or itemData.isMana then
            -- FU Blizzard
            itemDescription = Engine.ReplaceFakeSpace(itemDescription)
            -- Utility.Debug("desc: ", itemDescription)

            -- parse for health and/or mana
            itemData = Engine.ParseValues(itemData, itemDescription)
        end
    end

    itemData = Engine.PostParseUpdate(itemData)

    return itemData
end

function Engine.CheckRestrictionEntry(entry)
    local matchMode = entry.matchMode or "any"
    local conditions = 0
    local matches = 0

    if entry.inInstanceIds ~= nil then
        conditions = conditions + 1
        if Utility.IsPlayerInInstanceId(entry.inInstanceIds) then
            matches = matches + 1
        end
    end
    if entry.inMapIds ~= nil then
        conditions = conditions + 1
        if Utility.IsPlayerInMapId(entry.inMapIds) then
            matches = matches + 1
        end
    end
    if entry.inInstanceTypes ~= nil then
        conditions = conditions + 1
        if Utility.IsPlayerInInstanceType(entry.inInstanceTypes) then
            matches = matches + 1
        end
    end
    if entry.inSubZones ~= nil then
        conditions = conditions + 1
        if Utility.IsPlayerInSubZoneName(entry.inSubZones) then
            matches = matches + 1
        end
    end

    if entry.pvp ~= nil then
        if entry.pvp.bg ~= nil then
            conditions = conditions + 1
            if Utility.IsClassic then
                if entry.pvp.bg == true and C_PvP.IsPVPMap() then
                    matches = matches + 1
                end
            end
            if Utility.IsRetail then -- since version 8.2.0
                if entry.pvp.bg == true and C_PvP.IsBattleground() then
                    matches = matches + 1
                end
            end
        end

        if entry.pvp.arena ~= nil then
            conditions = conditions + 1
            if Utility.IsRetail then -- since version 8.2.0
                if entry.pvp.arena == true and C_PvP.IsArena() then
                    matches = matches + 1
                end
            end
        end

        if entry.pvp.brawl ~= nil then
            conditions = conditions + 1
            if Utility.IsRetail then -- since version 7.2.0
                if entry.pvp.brawl == true and C_PvP.IsInBrawl() then
                    matches = matches + 1
                end
            end
        end

        if entry.pvp.ratedBg ~= nil then
            conditions = conditions + 1
            if Utility.IsRetail then -- since version 8.2.0
                if entry.pvp.ratedBg == true and C_PvP.IsRatedBattleground() then
                    matches = matches + 1
                end
            end
        end

        if entry.pvp.ratedArena ~= nil then
            conditions = conditions + 1
            if Utility.IsRetail then -- since version 8.2.0
                if entry.pvp.ratedArena == true and C_PvP.IsRatedArena() then
                    matches = matches + 1
                end
            end
        end
    end

    if matchMode == "none" then
        return matches == 0
    end
    if matchMode == "one" then
        return matches == 1
    end
    if matchMode == "any" then
        return matches >= 1
    end
    if matchMode == "all" then
        return matches == conditions
    end

    -- allow for exact matches
    if type(matchMode) == "number" then
        return matches == matchMode
    end

    return false
end

function Engine.ExtractValue(value, indexes)
    if indexes then
        if type(indexes) == "table" then
            local value1 = Engine.StripThousandSeparator(value[indexes[1]])
            local value2 = Engine.StripThousandSeparator(value[indexes[2]])
            return (tonumber(value1) + tonumber(value2)) / 2
        elseif type(indexes) == "number" then
            local value = Engine.StripThousandSeparator(value[indexes])
            return tonumber(value)
        end
    end
    return 0
end

function Engine.LoopPattern(itemData, itemDescription, patterns)
    for k, v in ipairs(patterns) do
        local value = Engine.Match(itemDescription, v.pattern)
        if value and (#value > 0) then
            if v.healthIndex then
                itemData.health = Engine.ExtractValue(value, v.healthIndex)
                if v.pct then
                    itemData.health = itemData.health / 100
                end
            end
            if v.manaIndex then
                itemData.mana = Engine.ExtractValue(value, v.manaIndex)
                if v.pct then
                    itemData.mana = itemData.mana / 100
                end
            end
            itemData.isPct = v.pct
            break
        end
    end
    return itemData
end

function Engine.ParseValues(itemData, itemDescription)
    if itemData.isHealth and itemData.isMana then
        if Utility.StringContains(itemDescription, Locales.KeyWords.Restores:lower()) then
            -- loop on mixed Health+Mana pattern here
            itemData = Engine.LoopPattern(itemData, itemDescription, Locales.Patterns.HealthAndMana)
            if itemData.isOverTime and itemData.health and (itemData.health > 0) and itemData.mana and (itemData.mana > 0) then
                local overTime = string_match(itemDescription, Locales.Patterns.OverTime)
                if overTime then
                    itemData.isOverTime = true
                    itemData.overTime = tonumber(overTime)
                end
            end
        end
    else
        if itemData.isHealth then
            if itemData.isBandage then
                if Utility.StringContains(itemDescription, Locales.KeyWords.Heals:lower()) then
                    -- loop on Bandage pattern here
                    itemData = Engine.LoopPattern(itemData, itemDescription, Locales.Patterns.Bandage)
                end
            else
                if Utility.StringContains(itemDescription, Locales.KeyWords.Restores:lower()) then
                    -- loop on Health pattern here
                    itemData = Engine.LoopPattern(itemData, itemDescription, Locales.Patterns.Health)
                    if itemData.health and (itemData.health > 0) and itemData.isOverTime then
                        local overTime = string_match(itemDescription, Locales.Patterns.OverTime)
                        if overTime then
                            itemData.isOverTime = true
                            itemData.overTime = tonumber(overTime)
                        end
                    end
                end
            end
        end
        if itemData.isMana then
            if Utility.StringContains(itemDescription, Locales.KeyWords.Restores:lower()) then
                -- loop on Mana pattern here
                itemData = Engine.LoopPattern(itemData, itemDescription, Locales.Patterns.Mana)
                if itemData.mana and (itemData.mana > 0) and itemData.isOverTime then
                    local overTime = string_match(itemDescription, Locales.Patterns.OverTime)
                    if overTime then
                        itemData.isOverTime = true
                        itemData.overTime = tonumber(overTime)
                    end
                end
            end
        end
    end
    return itemData
end

function Engine.Match(text, pattern)
    local p = {string_match(text, pattern)}
    return p
end

function Engine.ReplaceFakeSpace(text)
    local t = string_gsub(text, " ", " ") -- WTF Blizzard !
    return t
end

function Engine.StripThousandSeparator(text)
    if type(Locales.ThousandSeparator) == "string" then
        text = string_gsub(text, Locales.ThousandSeparator, "")
    elseif type(Locales.ThousandSeparator) == "table" then
        for i, v in ipairs(Locales.ThousandSeparator) do
            text = string_gsub(text, v, "")
        end
    end
    return text
end

ns.Engine = Engine
