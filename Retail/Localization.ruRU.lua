local _, ns = ...
-- Translator ZamestoTV
-- Imports
local Utility = ns.Utility

if Utility.IsRetail and GetLocale() == "ruRU" then
    -- Local namespace
    local Locales = {}

    Locales.ThousandSeparator = " "
    Locales.DecimalSeparator = ","

    Locales.KeyWords = {}
    Locales.KeyWords.Use = "Использовать"
    Locales.KeyWords.Restores = "Восстанавливает"
    Locales.KeyWords.Heals = "Исцеляет"
    Locales.KeyWords.Consume = "Потребляет"
    Locales.KeyWords.ConjuredItem = { "Сотворённый предмет", "Камень маны" }
    Locales.KeyWords.Health = { "здоровье", "мгновенно исцеляет" }
    Locales.KeyWords.Damage = "урон"
    Locales.KeyWords.Mana = "мана"
    Locales.KeyWords.WellFed = { "хорошо накормлен", "также увеличивает", "также восстанавливает", "проведено не менее" }
    Locales.KeyWords.ToxicPotion = "гнусное зелье"
    Locales.KeyWords.OverTime = "в секунду в течение"

    Locales.KeyWords.QuietContemplation = "Тихое созерцание"

    Locales.Patterns = {}
    Locales.Patterns.OverTime = "в течение (%d+) сек"

    Locales.Patterns.Bandage = {
        {
            pattern = "([%d,%.]+) урона",
            healthIndex = 1,
            manaIndex = nil,
            pct = false
        },
    }

    Locales.Patterns.HealthAndMana = {
        {
            pattern = "([%d%.]+)%% .-здоровья и маны",
            healthIndex = 1,
            manaIndex = 1,
            pct = true
        },
        {
            pattern = "([%d,%.]+) миллиона .-здоровья и маны",
            healthIndex = 1,
            manaIndex = 1,
            pct = false,
            factor = 1000000
        },
        {
            pattern = "([%d,%.]+) .-здоровья и маны",
            healthIndex = 1,
            manaIndex = 1,
            pct = false
        },
        {
            pattern = "([%d%.]+)%% .-здоровья.- ([%d%.]+)%%.-маны",
            healthIndex = 1,
            manaIndex = 2,
            pct = true
        },
        {
            pattern = "([%d,%.]+) миллиона .-здоровья.- ([%d,%.]+) миллиона .-маны",
            healthIndex = 1,
            manaIndex = 2,
            pct = false,
            factor = 1000000
        },
        {
            pattern = "([%d,%.]+) .-миллиона.- здоровья.- ([%d,%.]+) .-маны",
            healthIndex = 1,
            manaIndex = 2,
            pct = false,
            healthFactor = 1000000
        },
        {
            pattern = "([%d,%.]+) .-здоровья.- ([%d,%.]+) .-маны",
            healthIndex = 1,
            manaIndex = 2,
            pct = false
        },
    }

    Locales.Patterns.Health = {
        {
            pattern = "([%d%.]+)%%.-здоровья",
            healthIndex = 1,
            manaIndex = nil,
            pct = true
        },
        {
            pattern = "([%d,%.]+) .-миллиона .-здоровья",
            healthIndex = 1,
            manaIndex = nil,
            pct = false,
            factor = 1000000
        },
        {
            pattern = "([%d,%.]+).-здоровья",
            healthIndex = 1,
            manaIndex = nil,
            pct = false
        },
        {
            pattern = "мгновенно исцеляет вас на ([%d,%.]+),",
            healthIndex = 1,
            manaIndex = nil,
            pct = false
        },
    }

    Locales.Patterns.Mana = {
        {
            pattern = "([%d%.]+)%%.-маны",
            healthIndex = nil,
            manaIndex = 1,
            pct = true
        },
        {
            pattern = "([%d,%.]+) .-миллиона .-маны",
            healthIndex = nil,
            manaIndex = 1,
            pct = false,
            factor = 1000000
        },
        {
            pattern = "([%d,%.]+).-маны",
            healthIndex = nil,
            manaIndex = 1,
            pct = false
        },
    }

    -- Export
    ns.Locales = Locales
end
