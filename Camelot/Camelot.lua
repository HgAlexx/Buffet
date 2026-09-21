local _, ns = ...

-- Imports
local Utility = ns.Utility
local Locales = ns.Locales

if Utility.IsCamelot then
    -- Imports
    local ActiveConst = ns.ActiveConst
    local Engine = ns.Engine or {}

    local string_match = string.match

    function Engine.IsValidItemClasses(itemClassId, itemSubClassId)
        -- exclude cooking recipes
        if (itemClassId == 9) and (itemSubClassId == 5) then
            return false
        end
        -- exclude alchemy recipes
        if (itemClassId == 9) and (itemSubClassId == 6) then
            return false
        end
        -- exclude bandage book
        if (itemClassId == 9) and (itemSubClassId == 7) then
            return false
        end
        return true
    end

    function Engine.CheckUsable(text)
        if Engine.KeywordMatches(text, Locales.KeyWords.Use) and (
        Engine.KeywordMatches(text, Locales.KeyWords.Health) or
                Engine.KeywordMatches(text, Locales.KeyWords.Life) or
                Engine.KeywordMatches(text, Locales.KeyWords.Damage) or
                Engine.KeywordMatches(text, Locales.KeyWords.Mana)
        )
        then
            return true
        end
        return false
    end

    function Engine.CheckHealth(text, isBandage)
        if isBandage then
            if Engine.KeywordMatches(text, Locales.KeyWords.Damage) then
                return true
            end
        else
            if Engine.KeywordMatches(text, Locales.KeyWords.Health) or Engine.KeywordMatches(text, Locales.KeyWords.Life) then
                return true
            end
        end
        return false
    end

    function Engine.CheckBandage(text, itemClassId, itemSubClassId)
        local b = Engine.KeywordMatches(text, Locales.KeyWords.Bandage)
        return b
    end

    function Engine.CheckPotion(text, itemClassId, itemSubClassId)
        -- no solution for now
        return false
        --return Utility.StringContains(text, Locales.KeyWords.Potion)
    end

    function Engine.PostParseUpdate(itemData)
        if not itemData.isBandage and not itemData.isFoodAndDrink and not itemData.isConjured then
            itemData.isPotion = true
        end
        return itemData
    end

    function Engine.GetCategories(itemData)
        local Const = ns.Const
        local healthCats = {}
        local manaCats= {}

        -- food
        if itemData.isFoodAndDrink then
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

        -- bandage
        if itemData.isBandage then
            if itemData.isHealth then
                table.insert(healthCats, Const.BestCategories.bandage)
            end
            return healthCats, manaCats
        end

        -- potion
        if not itemData.isFoodAndDrink and not itemData.isConjured then
            if itemData.isHealth then
                table.insert(healthCats, Const.BestCategories.hppot)
            end
            if itemData.isMana then
                table.insert(manaCats, Const.BestCategories.mppot)
            end
            return healthCats, manaCats
        end

        --conjured
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
