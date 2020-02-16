local _, ns = ...

--[[
    Special char must be escaped for:
    - ThousandSeparator
    - Patterns
--]]

-- Imports
local Utility = ns.Utility

if Utility.IsRetail and GetLocale() == "frFR" then
    -- Local namespace
    local Locales = {}

    Locales.ThousandSeparator = " "

    Locales.KeyWords = {}
    Locales.KeyWords.Use = "Utiliser"
    Locales.KeyWords.Restores = "Rend"
    Locales.KeyWords.Heals = "Rend"
    Locales.KeyWords.ConjuredItem = "Objet invoqué"
    Locales.KeyWords.Health = "vie"
    Locales.KeyWords.Damage = "vie"
    Locales.KeyWords.Mana = "mana"
    Locales.KeyWords.WellFed = "bien nourri"
    Locales.KeyWords.OverTime = "par seconde pendant"

    Locales.Patterns = {}
    Locales.Patterns.OverTime = "pendant (%d+) s%."

    Locales.Patterns.Bandage = {
        {
            pattern = "([%d%s%.]+) .-vie",
            healthIndex = 1,
            manaIndex = nil,
            pct = false
        },
    }

    Locales.Patterns.HealthAndMana = {
        {
            pattern = "([%d%.]+)%%.-de vie et de mana",
            healthIndex = 1,
            manaIndex = 1,
            pct = true
        },
        {
            pattern = "([%d%.]+).-de vie et de mana",
            healthIndex = 1,
            manaIndex = 1,
            pct = false
        },
        {
            pattern = " ([%d%.]+)%% .-vie.- ([%d%.]+)%% .-mana",
            healthIndex = 1,
            manaIndex = 2,
            pct = true
        },
        {
            pattern = " ([%d%.]+) .-vie.- ([%d%.]+) .-mana",
            healthIndex = 1,
            manaIndex = 2,
            pct = false
        },
    }

    Locales.Patterns.Health = {
        {
            pattern = "([%d%.]+)%%.-vie",
            healthIndex = 1,
            manaIndex = nil,
            pct = true
        },
        {
            pattern = "([%d%s%.]+) .-vie",
            healthIndex = 1,
            manaIndex = nil,
            pct = false
        },
    }

    Locales.Patterns.Mana = {
        {
            pattern = "([%d%.]+)%%.-mana",
            healthIndex = nil,
            manaIndex = 1,
            pct = true
        },
        {
            pattern = "([%d%s%.]+) .-mana",
            healthIndex = nil,
            manaIndex = 1,
            pct = false
        },
    }

    -- Export
    ns.Locales = Locales
end

--if GetLocale() == "frFR" then
--    ThousandSeparator = " "
--
--    Patterns.FlatMana = "([%d%s%.]+) .-mana"
--    Patterns.PctMana = "([%d%.]+)%%.-mana"
--
--    -- Classic stuff
--    Classic_KeyWords.Bandage = "secourisme"
--
--    Classic_Patterns.Bandage = "rend ([%d%.]+) points de vie en ([%d%.]+) sec"
--
--    Classic_Patterns.Food = "rend ([%d%.]+) points de vie en ([%d%.]+) sec"
--    Classic_Patterns.Drink = "rend ([%d%.]+) points de mana en ([%d%.]+) sec"
--
--    Classic_Patterns.HealthPotion = "([%d%.]+) à ([%d%.]+) points de vie"
--    Classic_Patterns.ManaPotion = "([%d%.]+) à ([%d%.]+) points de mana"
--end
