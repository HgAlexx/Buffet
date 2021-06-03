local _, ns = ...

-- Imports
local Utility = ns.Utility
local Locales = ns.Locales

if Utility.IsRetail then
    -- Imports
    local ConstRetail = ns.ConstRetail
    local Engine = ns.Engine or {}

    local string_match = string.match

    function Engine.IsValidItemClasses(itemClassId, itemSubClassId)
        for _, v in pairs(ConstRetail.ValidItemClasses) do
            if itemClassId == v[1] and itemSubClassId == v[2] then
                return true
            end
        end
        return false
    end

    function Engine.CheckUsable(text)
        if Utility.StringContains(text, Locales.KeyWords.Use:lower()) and (
                Utility.StringContains(text, Locales.KeyWords.Health:lower()) or
                Utility.StringContains(text, Locales.KeyWords.Damage:lower()) or
                Utility.StringContains(text, Locales.KeyWords.Mana:lower()))
        then
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
            if Utility.StringContains(text, Locales.KeyWords.Health:lower()) then
                return true
            end
        end
        return false
    end

    function Engine.CheckBandage(text, itemClassId, itemSubClassId)
        return itemClassId == ConstRetail.ItemClasses.Consumable and itemSubClassId == ConstRetail.ItemConsumableSubClasses.Bandage
    end

    function Engine.CheckPotion(text, itemClassId, itemSubClassId)
        return itemClassId == ConstRetail.ItemClasses.Consumable and itemSubClassId == ConstRetail.ItemConsumableSubClasses.Potion
    end

    function Engine.PostParseUpdate(itemData)
        -- unused for retail (for now)
        return itemData
    end

    -- return true if the item is restricted, false otherwise
    function Engine.CheckRestriction(itemId)
        -- check restricted items against rules
        if ConstRetail.Restrictions[itemId] ~= nil then
            for _, entry in pairs(ConstRetail.Restrictions[itemId]) do
                local valid = Engine.CheckRestrictionEntry(entry)
                if valid then
                    return false -- if one entry is valid, item is not currently restricted
                end
            end
            return true -- no valid entry
        end

        return false -- no entry
    end

    function Engine.GetCategories(itemData)
        local Const = ns.Const
        local healthCats = {}
        local manaCats = {}

        -- food
        if (itemData.itemClassId == ConstRetail.ItemClasses.Consumable and itemData.itemSubClassId == ConstRetail.ItemConsumableSubClasses.FoodAndDrink) or
           (itemData.itemClassId == ConstRetail.ItemClasses.Tradeskill and itemData.itemSubClassId == ConstRetail.ItemTradeskillSubClasses.Cooking) or
           (itemData.itemClassId == ConstRetail.ItemClasses.Miscellaneous and itemData.itemSubClassId == ConstRetail.ItemMiscellaneousSubClasses.Reagent) then
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
        if itemData.itemClassId == ConstRetail.ItemClasses.Consumable and itemData.itemSubClassId == ConstRetail.ItemConsumableSubClasses.Potion then
            if itemData.isHealth then
                table.insert(healthCats, Const.BestCategories.hppot)
            end
            if itemData.isMana then
                table.insert(manaCats, Const.BestCategories.mppot)
            end
            return healthCats, manaCats
        end

        --  bandage
        if itemData.itemClassId == ConstRetail.ItemClasses.Consumable and itemData.itemSubClassId == ConstRetail.ItemConsumableSubClasses.Bandage then
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
