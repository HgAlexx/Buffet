local _, ns = ...

--[[
    Special char must be escaped for:
    - ThousandSeparator
    - Patterns
--]]

-- Imports
local Utility = ns.Utility

if Utility.IsTBC and GetLocale() == "deDE" then
    -- Local namespace
    local Locales = {}

    Locales.ThousandSeparator = "%."

    Locales.KeyWords = {}
    Locales.KeyWords.Use = "Benutzen"
    Locales.KeyWords.Restores = "Stellt"
    Locales.KeyWords.Heals = "Heilt"
    Locales.KeyWords.ConjuredItem = "Herbeigezauberter Gegenstand"
    Locales.KeyWords.Health = "gesundheit"
    Locales.KeyWords.Damage = "schaden"
    Locales.KeyWords.Life = "leben"
    Locales.KeyWords.Mana = "mana"
    Locales.KeyWords.WellFed = "essen verbringt"
    Locales.KeyWords.OverTime = " pro sekunde"
    Locales.KeyWords.Bandage = "erste hilfe"
    Locales.KeyWords.FoodAndDrink = "sitzen bleiben"

    Locales.Patterns = {}
    Locales.Patterns.OverTime = "von (%d+) sek"

    Locales.Patterns.Bandage = {
        {
            pattern = "heilt ([%d%.]+) sek%. lang insgesamt ([%d%.]+) schaden",
            healthIndex = 2,
            manaIndex = nil,
            pct = false
        },
    }

    Locales.Patterns.HealthAndMana = {
        {
            pattern = "stellt ([%d%.]+) bis ([%d%.]+) punkt%(e%) gesundheit.- stellt ([%d%.]+) bis ([%d%.]+) punkt%(e%) mana",
            healthIndex =  {1, 2},
            manaIndex =  {3, 4},
            pct = false
        },
        {
            pattern = "([%d%.]+) gesundheit und ([%d%.]+) mana",
            healthIndex =  1,
            manaIndex =  2,
            pct = false
        },
    }

    Locales.Patterns.Health = {
        {
            pattern = "stellt ([%d%.]+) bis ([%d%.]+) gesundheit wieder her",
            healthIndex = {1, 2},
            manaIndex = nil,
            pct = false
        },
        {
            pattern = "([%d%.]+) gesundheit wieder her",
            healthIndex = 1,
            manaIndex = nil,
            pct = false
        },
        {
            pattern = "stellt sofort ([%d%.]+) punkt%(e%) leben",
            healthIndex = 1,
            manaIndex = nil,
            pct = false,
        },
    }

    Locales.Patterns.Mana = {
        {
            pattern = "stellt ([%d%.]+) bis ([%d%.]+) mana wieder her",
            healthIndex = nil,
            manaIndex = {1, 2},
            pct = false
        },
        {
            pattern = "([%d%.]+) mana wieder her",
            healthIndex = nil,
            manaIndex = 1,
            pct = false
        },
    }

    -- Export
    ns.Locales = Locales
end
