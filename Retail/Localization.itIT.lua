local _, ns = ...

--[[
    Special char must be escaped for:
    - ThousandSeparator
    - Patterns
--]]

-- Imports
local Utility = ns.Utility

if Utility.IsRetail and GetLocale() == "itIT" then
    -- Local namespace
    local Locales = {}

    Locales.ThousandSeparator = "%."

    Locales.KeyWords = {}
    Locales.KeyWords.Use = "Usa"
    Locales.KeyWords.Restores = "Rigenera"
    Locales.KeyWords.Heals = "Cura"
    Locales.KeyWords.ConjuredItem = "Oggetto evocato"
    Locales.KeyWords.Health = "salute"
    Locales.KeyWords.Damage = "cura"
    Locales.KeyWords.Mana = "mana"
    Locales.KeyWords.WellFed = "ben nutrito"
    Locales.KeyWords.OverTime = "ogni secondo per"

    Locales.Patterns = {}
    Locales.Patterns.OverTime = "per (%d+) s"

    Locales.Patterns.Bandage = {
        {
            pattern = "di ([%d%.]+) in",
            healthIndex = 1,
            manaIndex = nil,
            pct = false
        },
    }

    Locales.Patterns.HealthAndMana = {
        {
            pattern = "([%d%.]+)%% .-salute e del mana",
            healthIndex = 1,
            manaIndex = 1,
            pct = true
        },
        {
            pattern = "([%d%.]+) .-salute e del mana",
            healthIndex = 1,
            manaIndex = 1,
            pct = false
        },
        {
            pattern = "([%d%.]+)%% .-salute.- ([%d%.]+)%% .-mana",
            healthIndex = 1,
            manaIndex = 2,
            pct = true
        },
        {
            pattern = "([%d%.]+) .-salute.- ([%d%.]+) .-mana",
            healthIndex = 1,
            manaIndex = 2,
            pct = false
        },
    }

    Locales.Patterns.Health = {
        {
            pattern = "([%d%.]+)%% .-salute",
            healthIndex = 1,
            manaIndex = nil,
            pct = true
        },
        {
            pattern = "([%d%.]+) .-salute",
            healthIndex = 1,
            manaIndex = nil,
            pct = false
        },
    }

    Locales.Patterns.Mana = {
        {
            pattern = "([%d%.]+)%% .-mana",
            healthIndex = nil,
            manaIndex = 1,
            pct = true
        },
        {
            pattern = "([%d%.]+) .-mana",
            healthIndex = nil,
            manaIndex = 1,
            pct = false
        },
    }

    -- Export
    ns.Locales = Locales
end
