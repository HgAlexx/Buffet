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
