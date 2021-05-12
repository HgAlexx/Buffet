local _, ns = ...

--[[
    Special char must be escaped for:
    - ThousandSeparator
    - Patterns
--]]

-- Imports
local Utility = ns.Utility

if Utility.IsTBC and GetLocale() == "esMX" then
    -- Local namespace
    local Locales = {}

    Locales.ThousandSeparator = "%."

    Locales.KeyWords = {}
    Locales.KeyWords.Use = "Uso"
    Locales.KeyWords.Restores = "Restaura"
    Locales.KeyWords.Heals = "Sana"
    Locales.KeyWords.ConjuredItem = "Objeto mágico"
    Locales.KeyWords.Health = "salud"
    Locales.KeyWords.Life = "vida"
    Locales.KeyWords.Damage = "daño"
    Locales.KeyWords.Mana = "maná"
    Locales.KeyWords.WellFed = "bien alimentado"
    Locales.KeyWords.OverTime = "por segundo durante"
    Locales.KeyWords.Bandage = "primeros auxilios"
    Locales.KeyWords.FoodAndDrink = "permanecer sentado mientras"

    Locales.Patterns = {}
    Locales.Patterns.OverTime = "durante (%d+) s"

    Locales.Patterns.Bandage = {
        {
            pattern = "sana ([%d%.]+) p%. de daño durante ([%d%.]+) s",
            healthIndex = 1,
            manaIndex = nil,
            pct = false
        },
    }

    Locales.Patterns.HealthAndMana = {
        {
            pattern = "([%d%.]+) a ([%d%.]+) p. de salud y ([%d%.]+) a ([%d%.]+) de maná",
            healthIndex = {1, 2},
            manaIndex = {3, 4},
            pct = false
        },
        {
            pattern = "([%d%.]+) a ([%d%.]+) p. de maná y ([%d%.]+) a ([%d%.]+) de salud",
            healthIndex = {3, 4},
            manaIndex = {1, 2},
            pct = false
        },
        {
            pattern = "([%d%.]+) .-salud.- ([%d%.]+) .-maná",
            healthIndex = 1,
            manaIndex = 2,
            pct = false
        },
        {
            pattern = "([%d%.]+) .-maná.- ([%d%.]+) .-salud",
            healthIndex = 2,
            manaIndex = 1,
            pct = false
        },
        {
            pattern = "([%d%.]+) .-salud y maná",
            healthIndex = 1,
            manaIndex = 1,
            pct = false
        },
    }

    Locales.Patterns.Health = {
        {
            pattern = "restaura ([%d%.]+) a ([%d%.]+) p. de salud",
            healthIndex = {1, 2},
            manaIndex = nil,
            pct = false
        },
        {
            pattern = "restaura ([%d%.]+) p%. de salud durante ([%d%.]+) s",
            healthIndex = 1,
            manaIndex = nil,
            pct = false
        },
        {
            pattern = "instantáneamente ([%d%.]+) p%. de vida",
            healthIndex = 1,
            manaIndex = nil,
            pct = false,
        },
    }

    Locales.Patterns.Mana = {
        {
            pattern = "restaura ([%d%.]+) a ([%d%.]+) p. de maná",
            healthIndex = nil,
            manaIndex = {1, 2},
            pct = false
        },
        {
            pattern = "restaura ([%d%.]+) p%. de maná durante ([%d%.]+) s",
            healthIndex = nil,
            manaIndex = 1,
            pct = false
        },
    }

    -- Export
    ns.Locales = Locales
end
