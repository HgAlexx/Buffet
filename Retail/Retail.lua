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

    function Engine.LoopPattern(itemData, itemDescription, patterns)
        for k, v in ipairs(patterns) do
            local value = Engine.Match(itemDescription, v.pattern)
            if value and (#value > 0) then
                if v.healthIndex and value[v.healthIndex] then
                    local healthValue = Engine.StripThousandSeparator(value[v.healthIndex])
                    itemData.health = tonumber(healthValue)
                    if v.pct then
                        itemData.health = itemData.health / 100
                    end
                end
                if v.manaIndex and value[v.manaIndex] then
                    local manaValue = Engine.StripThousandSeparator(value[v.manaIndex])
                    itemData.mana = tonumber(manaValue)
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

    function Engine.CheckRestriction(itemId)
        local isRestricted = false
        -- check restricted items against rules
        if ConstRetail.Restrictions[itemId] then
            if not isRestricted and ConstRetail.Restrictions[itemId].inInstanceIds then
                isRestricted = not Utility.IsPlayerInInstanceId(ConstRetail.Restrictions[itemId].inInstanceIds)
            end
            if not isRestricted and ConstRetail.Restrictions[itemId].inMapIds then
                isRestricted = not Utility.IsPlayerInMapId(ConstRetail.Restrictions[itemId].inMapIds)
            end
            if not isRestricted and ConstRetail.Restrictions[itemId].inInstanceTypes then
                isRestricted = not Utility.IsPlayerInInstanceType(ConstRetail.Restrictions[itemId].inInstanceTypes)
            end
            if not isRestricted and ConstRetail.Restrictions[itemId].inSubZones then
                isRestricted = not Utility.IsPlayerInSubZoneName(ConstRetail.Restrictions[itemId].inSubZones)
            end
        end
        return isRestricted
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
                else
                    table.insert(healthCats, Const.BestCategories.food)
                end
            end
            if itemData.isMana then
                if itemData.isConjured then
                    table.insert(manaCats, Const.BestCategories.percwater)
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
