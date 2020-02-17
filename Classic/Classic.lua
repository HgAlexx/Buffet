local _, ns = ...

-- Imports
local Utility = ns.Utility
local Locales = ns.Locales

if Utility.IsClassic then
    -- Imports
    local ConstClassic = ns.ConstClassic
    local Engine = ns.Engine or {}

    local string_match = string.match

    function Engine.IsValidItemClasses(itemClassId, itemSubClassId)
        -- unusable for now (ids all over the place)
        return true
    end

    function Engine.CheckUsable(text)
        if Utility.StringContains(text, Locales.KeyWords.Use:lower()) and (
        Utility.StringContains(text, Locales.KeyWords.Health:lower()) or
                Utility.StringContains(text, Locales.KeyWords.Life:lower()) or
                Utility.StringContains(text, Locales.KeyWords.Damage:lower()) or
                Utility.StringContains(text, Locales.KeyWords.Mana:lower())
        )
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
            if Utility.StringContains(text, Locales.KeyWords.Health:lower()) or Utility.StringContains(text, Locales.KeyWords.Life:lower()) then
                return true
            end
        end
        return false
    end

    function Engine.CheckBandage(text, itemClassId, itemSubClassId)
        local b = Utility.StringContains(text, Locales.KeyWords.Bandage)
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
                                itemData.health = itemData.health * tonumber(overTime)
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
                            itemData.mana = itemData.mana * tonumber(overTime)
                        end
                    end
                end
            end
        end
        return itemData
    end

    function Engine.CheckRestriction(itemId)
        local isRestricted = false
        -- check restricted items against rules
        if ConstClassic.Restrictions[itemId] then
            if not isRestricted and ConstClassic.Restrictions[itemId].inInstanceIds then
                isRestricted = not Utility.IsPlayerInInstanceId(ConstClassic.Restrictions[itemId].inInstanceIds)
            end
            if not isRestricted and ConstClassic.Restrictions[itemId].inInstanceTypes then
                isRestricted = not Utility.IsPlayerInInstanceType(ConstClassic.Restrictions[itemId].inInstanceTypes)
            end
            if not isRestricted and ConstClassic.Restrictions[itemId].inSubZones then
                isRestricted = not Utility.IsPlayerInSubZoneName(ConstClassic.Restrictions[itemId].inSubZones)
            end
        end
        return isRestricted
    end

    function Engine.GetCategories(itemData)
        local Const = ns.Const
        local cats = {}

        -- food
        --if not itemData.isPotion and not itemData.isBandage then
        if itemData.isFoodAndDrink then
            if itemData.isHealth then
                if itemData.isConjured then
                    table.insert(cats, Const.BestCategories.percfood)
                else
                    table.insert(cats, Const.BestCategories.food)
                end
            end
            if itemData.isMana then
                if itemData.isConjured then
                    table.insert(cats, Const.BestCategories.percwater)
                else
                    table.insert(cats, Const.BestCategories.water)
                end
            end
            return cats
        end
        if itemData.isBandage then
            if itemData.isHealth then
                table.insert(cats, Const.BestCategories.bandage)
            end
            return cats
        end
        if not itemData.isFoodAndDrink and not itemData.isConjured then
            if itemData.isHealth then
                table.insert(cats, Const.BestCategories.hppot)
            end
            if itemData.isMana then
                table.insert(cats, Const.BestCategories.hppot)
            end
            return cats
        end
        if itemData.isConjured then
            if itemData.isHealth then
                table.insert(cats, Const.BestCategories.healthstone)
            end
            if itemData.isMana then
                table.insert(cats, Const.BestCategories.managem)
            end
            return cats
        end
        return false
    end

    -- Export
    ns.Engine = Engine
end
