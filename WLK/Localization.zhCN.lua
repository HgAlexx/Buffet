local _, ns = ...

--[[
    Special char must be escaped for:
    - ThousandSeparator
    - Patterns
--]]

-- Imports
local Utility = ns.Utility

if Utility.IsWLK and GetLocale() == "zhCN" then
    -- Local namespace
    local Locales = {}

    Locales.ThousandSeparator = nil

    Locales.KeyWords = {}
    Locales.KeyWords.Use = "使用"
    Locales.KeyWords.Restores = "恢复"
    Locales.KeyWords.Heals = "治疗"
    Locales.KeyWords.ConjuredItem = {"魔法制造", "魔法宝石" }
    Locales.KeyWords.Health = "生命值"
    Locales.KeyWords.Life = "生命"
    Locales.KeyWords.Damage = "伤害"
    Locales.KeyWords.Mana = "法力值"
    Locales.KeyWords.WellFed = { "进食充分", "将提高", "恢复", "花费至少" }
    Locales.KeyWords.OverTime = "每秒恢复"
    Locales.KeyWords.Bandage = "急救"
    Locales.KeyWords.FoodAndDrink = "进食时必须保持坐姿"

    Locales.Patterns = {}
    Locales.Patterns.OverTime = "持续(%d+)秒"

    Locales.Patterns.Bandage = {
        {
            pattern = "在([%d%.]+)秒.-恢复.-([%d%.]+)点生命值",
            healthIndex = 2,
            manaIndex = nil,
            pct = false
        },
    }

    Locales.Patterns.HealthAndMana = {
        {
            pattern = "([%d,%.]+)点生命值.-([%d,%.]+)点法力值",
            healthIndex = 1,
            manaIndex = 2,
            pct = false
        },
    }

    Locales.Patterns.Health = {
        {
            pattern = "([%d%.]+)到([%d%.]+)点生命值",
            healthIndex = {1, 2},
            manaIndex = nil,
            pct = false
        },
        {
            pattern = "在([%d%.]+)秒.-恢复.-([%d%.]+)点生命值",
            healthIndex = 2,
            manaIndex = nil,
            pct = false
        },
        {
            pattern = "每秒恢复总生命值的([%d%.]+)%%",
            healthIndex = 1,
            manaIndex = nil,
            pct = false
        },
    }

    Locales.Patterns.Mana = {
        {
            pattern = "([%d%.]+)到([%d%.]+)点法力值",
            healthIndex = nil,
            manaIndex = {1, 2},
            pct = false
        },
        {
            pattern = "在([%d%.]+)秒.-恢复.-([%d%.]+)点法力值",
            healthIndex = nil,
            manaIndex = 2,
            pct = false
        },
        {
            pattern = "每秒恢复总法力值的([%d%.]+)%%",
            healthIndex = 1,
            manaIndex = nil,
            pct = false
        },
    }

    -- Export
    ns.Locales = Locales
end
