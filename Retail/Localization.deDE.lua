local _, ns = ...

--[[
    Special char must be escaped for:
    - ThousandSeparator
    - Patterns
--]]

-- Imports
local Utility = ns.Utility

if Utility.IsRetail and GetLocale() == "deDE" then
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
    Locales.KeyWords.Mana = "mana"
    Locales.KeyWords.WellFed = "essen verbringt"
    Locales.KeyWords.OverTime = " pro sekunde"

    Locales.Patterns = {}
    Locales.Patterns.OverTime = "von (%d+) sek"

    Locales.Patterns.Bandage = {
        {
            pattern = "([%d%.]+) schaden",
            healthIndex = 1,
            manaIndex = nil,
            pct = false
        },
    }

    Locales.Patterns.HealthAndMana = {
        {
            pattern = "([%d%.]+)%% eurer gesundheit und eures manas",
            healthIndex = 1,
            manaIndex = 1,
            pct = true
        },
        {
            pattern = "([%d%.]+)%% gesundheit und mana",
            healthIndex = 1,
            manaIndex = 1,
            pct = true
        },
        {
            pattern = "([%d%.]+) gesundheit und mana",
            healthIndex = 1,
            manaIndex = 1,
            pct = false
        },
        {
            pattern = "([%d%.]+)%% gesundheit.- ([%d%.]+)%% mana",
            healthIndex = 1,
            manaIndex = 2,
            pct = true
        },
        {
            pattern = "([%d%.]+) gesundheit.- ([%d%.]+) mana",
            healthIndex = 1,
            manaIndex = 2,
            pct = false
        },
    }

    Locales.Patterns.Health = {
        {
            pattern = "([%d%.]+)%% gesundheit",
            healthIndex = 1,
            manaIndex = nil,
            pct = true
        },
        {
            pattern = "([%d%.]+) gesundheit",
            healthIndex = 1,
            manaIndex = nil,
            pct = false
        },
    }

    Locales.Patterns.Mana = {
        {
            pattern = "([%d%.]+)%% mana",
            healthIndex = nil,
            manaIndex = 1,
            pct = true
        },
        {
            pattern = "([%d%.]+) mana",
            healthIndex = nil,
            manaIndex = 1,
            pct = false
        },
    }

    -- Export
    ns.Locales = Locales
end
