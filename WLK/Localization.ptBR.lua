local _, ns = ...

--[[
    Special char must be escaped for:
    - ThousandSeparator
    - Patterns
--]]

-- Imports
local Utility = ns.Utility

if Utility.IsWLK and GetLocale() == "ptBR" then
    -- Local namespace
    local Locales = {}

    Locales.ThousandSeparator = ","

    Locales.KeyWords = {}
    Locales.KeyWords.Use = { "Uso", "Usar" }
    Locales.KeyWords.Restores = { "Restaura", "Recupera" }
    Locales.KeyWords.Heals = "Cura"
    Locales.KeyWords.ConjuredItem = { "Item conjurado", "Mana Gem" }
    Locales.KeyWords.Health = "vida"
    Locales.KeyWords.Life = "vida"
    Locales.KeyWords.Damage = "vida"
    Locales.KeyWords.Mana = "mana"
    Locales.KeyWords.WellFed = { "bem alimentado", "gastar pelo menos", "passar pelo menos", "passar ao menos", "aumentará" }
    Locales.KeyWords.OverTime = { "ao longo de", "a cada segundo" }
    Locales.KeyWords.Bandage = "primeiros socorros"
    Locales.KeyWords.FoodAndDrink = { "sentado enquanto", "sentado durante" }

    Locales.Patterns = {}
    -- WLK tooltips often use "sec" instead of "s"; "s" also matches the start of "sec"
    Locales.Patterns.OverTime = { "ao longo de (%d+) s", "por (%d+) s" }

    Locales.Patterns.Bandage = {
        {
            pattern = "cura ([%d,%.]+) pontos de vida ao longo de ([%d%.]+) s",
            healthIndex = 1,
            manaIndex = nil,
            pct = false,
        },
    }

    Locales.Patterns.HealthAndMana = {
        {
            pattern = "([%d%.]+)%% .-vida e mana",
            healthIndex = 1,
            manaIndex = 1,
            pct = true
        },
        {
            pattern = "([%d,%.]+) para ([%d,%.]+) .-vida.- ([%d,%.]+) para ([%d,%.]+) .-mana",
            healthIndex = {1, 2},
            manaIndex = {3, 4},
            pct = false,
        },
        {
            pattern = "([%d,%.]+) to ([%d,%.]+) .-vida.- ([%d,%.]+) to ([%d,%.]+) .-mana",
            healthIndex = {1, 2},
            manaIndex = {3, 4},
            pct = false,
        },
        {
            pattern = "([%d,%.]+) para ([%d,%.]+) .-mana.- ([%d,%.]+) para ([%d,%.]+) .-vida",
            healthIndex = {3, 4},
            manaIndex = {1, 2},
            pct = false,
        },
        {
            pattern = "([%d,%.]+) to ([%d,%.]+) .-mana.- ([%d,%.]+) to ([%d,%.]+) .-vida",
            healthIndex = {3, 4},
            manaIndex = {1, 2},
            pct = false,
        },
        {
            pattern = "([%d,%.]+) .-vida e ([%d,%.]+) .-mana",
            healthIndex = 1,
            manaIndex = 2,
            pct = false,
        },
    }

    Locales.Patterns.Health = {
        {
            pattern = "([%d,%.]+) para ([%d,%.]+) .-vida",
            healthIndex = {1, 2},
            manaIndex = nil,
            pct = false,
        },
        {
            pattern = "([%d,%.]+) to ([%d,%.]+) .-vida",
            healthIndex = {1, 2},
            manaIndex = nil,
            pct = false,
        },
        {
            pattern = "([%d%.]+)%%.-vida",
            healthIndex = 1,
            manaIndex = nil,
            pct = true
        },
        {
            pattern = "instantaneamente ([%d,%.]+) .-vida",
            healthIndex = 1,
            manaIndex = nil,
            pct = false,
        },
        {
            pattern = "([%d,%.]+) .-vida ao longo de",
            healthIndex = 1,
            manaIndex = nil,
            pct = false,
        },
    }

    Locales.Patterns.Mana = {
        {
            pattern = "([%d,%.]+) para ([%d,%.]+) .-mana",
            healthIndex = nil,
            manaIndex = {1, 2},
            pct = false,
        },
        {
            pattern = "([%d,%.]+) to ([%d,%.]+) .-mana",
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
            pattern = "([%d,%.]+) .-mana ao longo de",
            healthIndex = nil,
            manaIndex = 1,
            pct = false,
        },
    }

    -- Export
    ns.Locales = Locales
end
