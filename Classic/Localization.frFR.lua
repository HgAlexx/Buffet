local _, ns = ...

--[[
    Special char must be escaped for:
    - ThousandSeparator
    - Patterns
--]]

-- Imports
local Utility = ns.Utility

if Utility.IsClassic and GetLocale() == "frFR" then
    -- Local namespace
    local Locales = {}

    Locales.ThousandSeparator = " "

    Locales.KeyWords = {}
    Locales.KeyWords.Use = "Utiliser"
    Locales.KeyWords.Restores = "Rend"
    Locales.KeyWords.Heals = "Rend"
    Locales.KeyWords.ConjuredItem = "Objet invoqué"
    Locales.KeyWords.Health = "vie"
    Locales.KeyWords.Life = "vie"
    Locales.KeyWords.Damage = "vie"
    Locales.KeyWords.Mana = "mana"
    Locales.KeyWords.WellFed = {"bien nourri", "augmente", "rend aussi"}
    Locales.KeyWords.OverTime = "par seconde pendant"
    Locales.KeyWords.Bandage = "secourisme"
    Locales.KeyWords.FoodAndDrink = "rester assis pendant"

    Locales.Patterns = {}
    Locales.Patterns.OverTime = "pendant (%d+) s"

    Locales.Patterns.Bandage = {
        {
            pattern = "rend ([%d%.]+) points de vie en ([%d%.]+) sec",
            healthIndex = 1,
            manaIndex = nil,
            pct = false
        },
    }

    Locales.Patterns.HealthAndMana = {
        {
            pattern = "([%d%.]+) à ([%d%.]+) points de vie.- ([%d%.]+) à ([%d%.]+) points de mana",
            healthIndex = {1, 2},
            manaIndex = {3, 4},
            pct = false,
        },
        {
            pattern = "([%d%.]+) à ([%d%.]+) points de mana.- ([%d%.]+) à ([%d%.]+) points de vie",
            healthIndex = {3, 4},
            manaIndex = {1, 2},
            pct = false,
        },
        {
            pattern = "rend ([%d%.]+) points de vie.- ([%d%.]+) points de mana en ([%d%.]+) sec",
            healthIndex = 1,
            manaIndex = 2,
            pct = false,
        },
    }

    Locales.Patterns.Health = {
        {
            pattern = "([%d%.]+) à ([%d%.]+) points de vie",
            healthIndex = {1, 2},
            manaIndex = nil,
            pct = false,
        },
        {
            pattern = "rend ([%d%.]+) points de vie en ([%d%.]+) sec",
            healthIndex = 1,
            manaIndex = nil,
            pct = false,
        },
        {
            pattern = "rend ([%d%.]+)%% de vos points de vie par seconde pendant ([%d%.]+) sec",
            healthIndex = 1,
            manaIndex = nil,
            pct = true,
        },
        {
            pattern = "rend instantanément ([%d%.]+) points de vie",
            healthIndex = 1,
            manaIndex = nil,
            pct = false,
        },
    }

    Locales.Patterns.Mana = {
        {
            pattern = "([%d%.]+) à ([%d%.]+) points de mana",
            healthIndex = nil,
            manaIndex = {1, 2},
            pct = false,
        },
        {
            pattern = "rend ([%d%.]+) points de mana en ([%d%.]+) sec",
            healthIndex = nil,
            manaIndex = 1,
            pct = false,
        },
    }

    -- Export
    ns.Locales = Locales
end
