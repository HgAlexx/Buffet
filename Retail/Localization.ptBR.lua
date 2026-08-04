local _, ns = ...

--[[
    Special char must be escaped for:
    - ThousandSeparator
    - Patterns
--]]

-- Imports
local Utility = ns.Utility

if Utility.IsRetail and GetLocale() == "ptBR" then
    -- Local namespace
    local Locales = {}

    Locales.ThousandSeparator = ","

    Locales.KeyWords = {}
    Locales.KeyWords.Use = { "Uso", "Usar" }
    Locales.KeyWords.Restores = { "Restaura", "Recupera" }
    Locales.KeyWords.Heals = "Cura"
    Locales.KeyWords.Consume = "Consome"
    Locales.KeyWords.ConjuredItem = { "Item conjurado", "Mana Gem" }
    Locales.KeyWords.Health = { "vida", "curar instantaneamente", "instantaneamente" }
    Locales.KeyWords.Damage = { "dano", "vida" }
    Locales.KeyWords.Mana = "mana"
    Locales.KeyWords.WellFed = { "bem alimentado", "gastar pelo menos", "passar pelo menos", "passar ao menos", "aumentará" }
    Locales.KeyWords.ToxicPotion = "mistura abjeta"
    Locales.KeyWords.OverTime = { "ao longo de", "a cada segundo" }
    Locales.KeyWords.FoodAndDrink = { "sentado enquanto", "sentado durante" }

    Locales.KeyWords.QuietContemplation = "Contemplação Silenciosa"

    Locales.Patterns = {}
    Locales.Patterns.OverTime = { "ao longo de (%d+) s", "por (%d+) s" }

    Locales.Patterns.Bandage = {
        {
            pattern = "([%d,%.]+) de dano",
            healthIndex = 1,
            manaIndex = nil,
            pct = false
        },
        {
            pattern = "([%d,%.]+) pontos de vida",
            healthIndex = 1,
            manaIndex = nil,
            pct = false
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
            pattern = "([%d%.]+)%% de vida e ([%d%.]+)%% de mana",
            healthIndex = 1,
            manaIndex = 2,
            pct = true
        },
        {
            pattern = "([%d,%.]+) milh[oõ][eẽ]?[ns]? .-vida e mana",
            healthIndex = 1,
            manaIndex = 1,
            pct = false,
            factor = 1000000
        },
        {
            pattern = "([%d,%.]+) .-vida e mana",
            healthIndex = 1,
            manaIndex = 1,
            pct = false
        },
        {
            pattern = "([%d%.]+)%% .-vida.- ([%d%.]+)%%.-mana",
            healthIndex = 1,
            manaIndex = 2,
            pct = true
        },
        {
            pattern = "([%d,%.]+) milh[oõ][eẽ]?[ns]? .-vida.- ([%d,%.]+) milh[oõ][eẽ]?[ns]? .-mana",
            healthIndex = 1,
            manaIndex = 2,
            pct = false,
            factor = 1000000
        },
        {
            pattern = "([%d,%.]+) .-milh[oõ].- vida.- ([%d,%.]+) .-mana",
            healthIndex = 1,
            manaIndex = 2,
            pct = false,
            healthFactor = 1000000
        },
        {
            pattern = "([%d,%.]+) .-vida e ([%d,%.]+) .-mana",
            healthIndex = 1,
            manaIndex = 2,
            pct = false
        },
        {
            pattern = "([%d,%.]+) .-vida.- ([%d,%.]+) .-mana",
            healthIndex = 1,
            manaIndex = 2,
            pct = false
        },
    }

    Locales.Patterns.Health = {
        {
            pattern = "([%d%.]+)%%.-vida",
            healthIndex = 1,
            manaIndex = nil,
            pct = true
        },
        {
            pattern = "([%d,%.]+) .-milh[oõ].- vida",
            healthIndex = 1,
            manaIndex = nil,
            pct = false,
            factor = 1000000
        },
        {
            pattern = "instantaneamente ([%d,%.]+)%%",
            healthIndex = 1,
            manaIndex = nil,
            pct = true
        },
        {
            pattern = "instantaneamente ([%d,%.]+)",
            healthIndex = 1,
            manaIndex = nil,
            pct = false
        },
        {
            pattern = "curar instantaneamente ([%d,%.]+)",
            healthIndex = 1,
            manaIndex = nil,
            pct = false
        },
        {
            pattern = "([%d,%.]+) para ([%d,%.]+) .-vida",
            healthIndex = {1, 2},
            manaIndex = nil,
            pct = false
        },
        {
            pattern = "([%d,%.]+) to ([%d,%.]+) .-vida",
            healthIndex = {1, 2},
            manaIndex = nil,
            pct = false
        },
        {
            pattern = "([%d,%.]+).-vida",
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
            pattern = "([%d,%.]+) .-milh[oõ].- mana",
            healthIndex = nil,
            manaIndex = 1,
            pct = false,
            factor = 1000000
        },
        {
            pattern = "([%d,%.]+) para ([%d,%.]+) .-mana",
            healthIndex = nil,
            manaIndex = {1, 2},
            pct = false
        },
        {
            pattern = "([%d,%.]+) to ([%d,%.]+) .-mana",
            healthIndex = nil,
            manaIndex = {1, 2},
            pct = false
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
