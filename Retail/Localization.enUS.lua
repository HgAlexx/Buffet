local _, ns = ...

--[[
    Special char must be escaped for:
    - ThousandSeparator
    - Patterns
--]]

-- Imports
local Utility = ns.Utility

if Utility.IsRetail then
    -- Local namespace
    local Locales = {}

    Locales.ThousandSeparator = ","

    Locales.KeyWords = {}
    Locales.KeyWords.Use = "Use"
    Locales.KeyWords.Restores = "Restores"
    Locales.KeyWords.Heals = "Heals"
    Locales.KeyWords.ConjuredItem = "Conjured item"
    Locales.KeyWords.Health = "health"
    Locales.KeyWords.Damage = "damage"
    Locales.KeyWords.Mana = "mana"
    Locales.KeyWords.WellFed = "well fed"
    Locales.KeyWords.OverTime = "per second for"

    Locales.Patterns = {}
    Locales.Patterns.OverTime = "for (%d+) sec"

    Locales.Patterns.Bandage = {
        {
            pattern = "([%d,%.]+) damage",
            healthIndex = 1,
            manaIndex = nil,
            pct = false
        },
    }

    Locales.Patterns.HealthAndMana = {
        {
            pattern = "([%d%.]+)%% .-health and mana",
            healthIndex = 1,
            manaIndex = 1,
            pct = true
        },
        {
            pattern = "([%d,%.]+) .-health and mana",
            healthIndex = 1,
            manaIndex = 1,
            pct = false
        },
        {
            pattern = "([%d%.]+)%% .-health.- ([%d%.]+)%%.-mana",
            healthIndex = 1,
            manaIndex = 2,
            pct = true
        },
        {
            pattern = "([%d,%.]+) .-health.- ([%d,%.]+).-mana",
            healthIndex = 1,
            manaIndex = 2,
            pct = false
        },
    }

    Locales.Patterns.Health = {
        {
            pattern = "([%d%.]+)%%.-health",
            healthIndex = 1,
            manaIndex = nil,
            pct = true
        },
        {
            pattern = "([%d,%.]+).-health",
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
            pattern = "([%d,%.]+).-mana",
            healthIndex = nil,
            manaIndex = 1,
            pct = false
        },
    }

    -- Export
    ns.Locales = Locales
end

