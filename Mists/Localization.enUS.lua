local _, ns = ...

--[[
    Special char must be escaped for:
    - ThousandSeparator
    - Patterns
--]]

-- Imports
local Utility = ns.Utility

if Utility.IsMists then
    -- Local namespace
    local Locales = {}

    Locales.ThousandSeparator = ","

    Locales.KeyWords = {}
    Locales.KeyWords.Use = "Use"
    Locales.KeyWords.Restores = "Restores"
    Locales.KeyWords.Heals = "Heals"
    Locales.KeyWords.ConjuredItem = { "Conjured item", "Mana Gem" }
    Locales.KeyWords.Health = "health"
    Locales.KeyWords.Life = "life"
    Locales.KeyWords.Damage = "damage"
    Locales.KeyWords.Mana = "mana"
    Locales.KeyWords.WellFed = { "well fed", "also increase", "also restore", "spent at least" }
    Locales.KeyWords.OverTime = "per second for"
    Locales.KeyWords.Bandage = "first aid"
    Locales.KeyWords.FoodAndDrink = "remain seated while"

    Locales.Patterns = {}
    Locales.Patterns.OverTime = "for (%d+) sec"

    Locales.Patterns.Bandage = {
        {
            pattern = "heals ([%d,%.]+) damage over ([%d%.]+) sec",
            healthIndex = 1,
            manaIndex = nil,
            pct = false,
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
            pattern = "([%d,%.]+) to ([%d,%.]+) health.- ([%d,%.]+) to ([%d,%.]+) mana",
            healthIndex = {1, 2},
            manaIndex = {3, 4},
            pct = false,
        },
        {
            pattern = "([%d,%.]+) to ([%d,%.]+) mana.- ([%d,%.]+) to ([%d,%.]+) health",
            healthIndex = {3, 4},
            manaIndex = {1, 2},
            pct = false,
        },
        {
            pattern = "restores ([%d,%.]+) health.- ([%d,%.]+) mana over ([%d%.]+) ",
            healthIndex = 1,
            manaIndex = 2,
            pct = false,
        },
    }

    Locales.Patterns.Health = {
        {
            pattern = "([%d,%.]+) to ([%d,%.]+) health",
            healthIndex = {1, 2},
            manaIndex = nil,
            pct = false,
        },
        {
            pattern = "([%d%.]+)%%.-health",
            healthIndex = 1,
            manaIndex = nil,
            pct = true
        },
        {
            pattern = "restores ([%d,%.]+) health over ([%d%.]+) ",
            healthIndex = 1,
            manaIndex = nil,
            pct = false,
        },
        {
            pattern = "instantly restores ([%d,%.]+) life",
            healthIndex = 1,
            manaIndex = nil,
            pct = false,
        },
    }

    Locales.Patterns.Mana = {
        {
            pattern = "([%d,%.]+) to ([%d,%.]+) mana",
            healthIndex = nil,
            manaIndex = {1, 2},
            pct = false,
        },
        {
            pattern = "([%d%.]+)%%.-mana",
            healthIndex = nil,
            manaIndex = 1,
            pct = true
        },
        {
            pattern = "restores ([%d,%.]+) mana over ([%d%.]+) ",
            healthIndex = nil,
            manaIndex = 1,
            pct = false,
        },
    }

    -- Export
    ns.Locales = Locales
end
