local _, ns = ...

--[[
    Special char must be escaped for:
    - ThousandSeparator
    - Patterns
--]]

-- Imports
local Utility = ns.Utility

if Utility.IsMists and GetLocale() == "koKR" then
    -- Local namespace
    local Locales = {}

    Locales.ThousandSeparator = nil

    Locales.KeyWords = {}
    Locales.KeyWords.Use = "사용 효과"
    Locales.KeyWords.Restores = "회복"
    Locales.KeyWords.Heals = "회복"
    Locales.KeyWords.ConjuredItem = { "창조 아이템", "마나석" }
    Locales.KeyWords.Health = "생명력"
    Locales.KeyWords.Damage = "회복시킵니다"
    Locales.KeyWords.Life = "생명력"
    Locales.KeyWords.Mana = "마나"
    Locales.KeyWords.WellFed = { "포만감", "추가로", "꾸준히" }
    Locales.KeyWords.OverTime = "초에 걸쳐"
    Locales.KeyWords.Bandage = "붕대"
    Locales.KeyWords.FoodAndDrink = "앉아 있어야 합니다"

    Locales.Patterns = {}
    Locales.Patterns.OverTime = "(%d+)초에 걸쳐"

    Locales.Patterns.Bandage = {
        {
            pattern = "([%d%.]+)초에 걸쳐 생명력을 ([%d%.]+)만큼 회복시킵니다",
            healthIndex = 2,
            manaIndex = nil,
            pct = false
        },
    }

    Locales.Patterns.HealthAndMana = {

        {
            pattern = "([%d%.]+)~([%d%.]+)의 생명력.- ([%d%.]+)~([%d%.]+)의 마나",
            healthIndex = {1, 2},
            manaIndex = {3, 4},
            pct = false,
        },
        {
            pattern = "([%d%.]+)~([%d%.]+)의 마나.- ([%d%.]+)~([%d%.]+)의 생명력",
            healthIndex = {3, 4},
            manaIndex = {1, 2},
            pct = false,
        },
        {
            pattern = "([%d%.]+)초에 걸쳐 ([%d%.]+)의 생명력.- ([%d%.]+)의 마나를 회복합니다",
            healthIndex = 2,
            manaIndex = 3,
            pct = false,
        },
    }

    Locales.Patterns.Health = {
        {
            pattern = "([%d%.]+)~([%d%.]+)의 생명력",
            healthIndex = {1, 2},
            manaIndex = nil,
            pct = false
        },
        {
            pattern = "([%d%.]+)초에 걸쳐 총 ([%d%.]+)의 생명력",
            healthIndex = 1,
            manaIndex = nil,
            pct = false
        },
        {
            pattern = "즉시 ([%d%.]+)의 생명력을 회복",
            healthIndex = 1,
            manaIndex = nil,
            pct = false,
        },
    }

    Locales.Patterns.Mana = {
        {
            pattern = "([%d%.]+)~([%d%.]+)의 마나",
            healthIndex = nil,
            manaIndex = {1, 2},
            pct = false
        },
        {
            pattern = "([%d%.]+)초에 걸쳐 총 ([%d%.]+)의 마나",
            healthIndex = nil,
            manaIndex = 1,
            pct = false
        },
    }

    -- Export
    ns.Locales = Locales
end
