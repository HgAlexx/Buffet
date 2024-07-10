local _, ns = ...

-- Imports
local Utility = ns.Utility
local Locales = ns.Locales

if Utility.IsRetail then
    -- Imports
    local ActiveConst = ns.ActiveConst
    local Engine = ns.Engine or {}

    if C_TooltipInfo and C_TooltipInfo.GetHyperlink then
        function Engine.ScanTooltip(itemLink)
            local texts = {}
            local lineCount = 0
            local tooltipData = C_TooltipInfo.GetHyperlink(itemLink)

            local linesTotal = Utility.TableCount(tooltipData.lines)
            for i = 2, linesTotal do
                local text = tooltipData.lines[i].leftText or ""
                text = Utility.Trim(text)
                if text ~= "" then
                    texts[lineCount] = text
                    lineCount = lineCount + 1
                end
            end

            return texts
        end
    end

    function Engine.IsValidItemClasses(itemClassId, itemSubClassId)
        for _, v in pairs(ActiveConst.ValidItemClasses) do
            if itemClassId == v[1] and itemSubClassId == v[2] then
                return true
            end
        end
        return false
    end

    function Engine.CheckUsable(text)
        local health = false
        if type(Locales.KeyWords.Health) == "table" then
            for _, s in pairs(Locales.KeyWords.Health) do
                if Utility.StringContains(text, s:lower()) then
                    health = true
                    break
                end
            end
        elseif type(Locales.KeyWords.Health) == "string" then
            health = Utility.StringContains(text, Locales.KeyWords.Health:lower())
        end

        local damage = Utility.StringContains(text, Locales.KeyWords.Damage:lower())
        local mana = Utility.StringContains(text, Locales.KeyWords.Mana:lower())

        if Utility.StringContains(text, Locales.KeyWords.Use:lower()) and (health or damage or mana) then
            return true
        end
        return false
    end

    function Engine.CheckHealth(text, isBandage)
        if isBandage then
            if Utility.StringContains(text, Locales.KeyWords.Damage:lower()) then
                return true
            end
        else
            local health = false
            if type(Locales.KeyWords.Health) == "table" then
                for _, s in pairs(Locales.KeyWords.Health) do
                    if Utility.StringContains(text, s:lower()) then
                        health = true
                        break
                    end
                end
            elseif type(Locales.KeyWords.Health) == "string" then
                health = Utility.StringContains(text, Locales.KeyWords.Health:lower())
            end
            return health
        end
        return false
    end

    function Engine.CheckBandage(text, itemClassId, itemSubClassId)
        return itemClassId == ActiveConst.ItemClasses.Consumable and itemSubClassId == ActiveConst.ItemConsumableSubClasses.Bandage
    end

    function Engine.CheckPotion(text, itemClassId, itemSubClassId)
        return itemClassId == ActiveConst.ItemClasses.Consumable and itemSubClassId == ActiveConst.ItemConsumableSubClasses.Potion
    end

    function Engine.PostParseUpdate(itemData)
        -- unused for retail (for now)
        return itemData
    end

    function Engine.GetCategories(itemData)
        local Const = ns.Const
        local healthCats = {}
        local manaCats = {}

        -- food
        if (itemData.itemClassId == ActiveConst.ItemClasses.Consumable and itemData.itemSubClassId == ActiveConst.ItemConsumableSubClasses.FoodAndDrink) or
           (itemData.itemClassId == ActiveConst.ItemClasses.Tradeskill and itemData.itemSubClassId == ActiveConst.ItemTradeskillSubClasses.Cooking) or
           (itemData.itemClassId == ActiveConst.ItemClasses.Miscellaneous and itemData.itemSubClassId == ActiveConst.ItemMiscellaneousSubClasses.Reagent) then
            if itemData.isHealth then
                if itemData.isConjured then
                    table.insert(healthCats, Const.BestCategories.percfood)
                elseif itemData.isWellFed then
                    table.insert(healthCats, Const.BestCategories.wellfedfood)
                else
                    table.insert(healthCats, Const.BestCategories.food)
                end
            end
            if itemData.isMana then
                if itemData.isConjured then
                    table.insert(manaCats, Const.BestCategories.percwater)
                elseif itemData.isWellFed then
                    table.insert(manaCats, Const.BestCategories.wellfedwater)
                else
                    table.insert(manaCats, Const.BestCategories.water)
                end
            end
            return healthCats, manaCats
        end

        -- potion
        if itemData.itemClassId == ActiveConst.ItemClasses.Consumable and itemData.itemSubClassId == ActiveConst.ItemConsumableSubClasses.Potion then
            if itemData.isHealth then
                if itemData.isToxicPotion then
                    table.insert(healthCats, Const.BestCategories.toxicpot)
                else
                    table.insert(healthCats, Const.BestCategories.hppot)
                end
            end
            if itemData.isMana then
                table.insert(manaCats, Const.BestCategories.mppot)
            end
            return healthCats, manaCats
        end

        --  bandage
        if itemData.itemClassId == ActiveConst.ItemClasses.Consumable and itemData.itemSubClassId == ActiveConst.ItemConsumableSubClasses.Bandage then
            if itemData.isHealth then
                table.insert(healthCats, Const.BestCategories.bandage)
            end
            return healthCats, manaCats
        end

        -- conjured
        if itemData.isConjured then
            if itemData.isHealth then
                table.insert(healthCats, Const.BestCategories.healthstone)
            end
            if itemData.isMana then
                table.insert(manaCats, Const.BestCategories.managem)
            end
            return healthCats, manaCats
        end

        return false, false
    end

    -- Export
    ns.Engine = Engine
end
