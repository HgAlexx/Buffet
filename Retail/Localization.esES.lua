local _, ns = ...

--[[
    Special char must be escaped for:
    - ThousandSeparator
    - Patterns
--]]

-- Imports
local Utility = ns.Utility

if Utility.IsRetail and GetLocale() == "esES" then
    -- Local namespace
    local Locales = {}

    Locales.ThousandSeparator = "%."

    Locales.KeyWords = {}
    Locales.KeyWords.Use = "Uso"
    Locales.KeyWords.Restores = "Restaura"
    Locales.KeyWords.Heals = "Sana"
    Locales.KeyWords.ConjuredItem = "Objeto mágico"
    Locales.KeyWords.Health = "salud"
    Locales.KeyWords.Damage = "daño"
    Locales.KeyWords.Mana = "maná"
    Locales.KeyWords.WellFed = "bien alimentado"
    Locales.KeyWords.OverTime = "por segundo durante"

    Locales.Patterns = {}
    Locales.Patterns.OverTime = "durante (%d+) s"

    Locales.Patterns.Bandage = {
        {
            pattern = "([%d%.]+).-daño",
            healthIndex = 1,
            manaIndex = nil,
            pct = false
        },
    }

    Locales.Patterns.HealthAndMana = {
        {
            pattern = "([%d%.]+)%% .-salud y maná",
            healthIndex = 1,
            manaIndex = 1,
            pct = true
        },
        {
            pattern = "([%d%.]+) .-salud y maná",
            healthIndex = 1,
            manaIndex = 1,
            pct = false
        },
        {
            pattern = "([%d%.]+)%% .-salud.- ([%d%.]+)%% .-maná",
            healthIndex = 1,
            manaIndex = 2,
            pct = true
        },
        {
            pattern = "([%d%.]+) .-salud.- ([%d%.]+) .-maná",
            healthIndex = 1,
            manaIndex = 2,
            pct = false
        },
    }

    Locales.Patterns.Health = {
        {
            pattern = "([%d%.]+)%% .-salud",
            healthIndex = 1,
            manaIndex = nil,
            pct = true
        },
        {
            pattern = "([%d%.]+) .-salud",
            healthIndex = 1,
            manaIndex = nil,
            pct = false
        },
    }

    Locales.Patterns.Mana = {
        {
            pattern = "([%d%.]+)%% .-maná",
            healthIndex = nil,
            manaIndex = 1,
            pct = true
        },
        {
            pattern = "([%d%.]+) .-maná",
            healthIndex = nil,
            manaIndex = 1,
            pct = false
        },
    }

    -- Export
    ns.Locales = Locales
end
