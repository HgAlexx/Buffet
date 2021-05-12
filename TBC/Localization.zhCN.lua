local _, ns = ...

--[[
    Special char must be escaped for:
    - ThousandSeparator
    - Patterns
--]]

-- Imports
local Utility = ns.Utility

if Utility.IsTBC and GetLocale() == "zhCN" then
    -- Local namespace
    local Locales = {}

    Locales.ThousandSeparator = ","

    Locales.KeyWords = {}
    Locales.KeyWords.Use = "使用"
    Locales.KeyWords.Restores = "恢复"
    Locales.KeyWords.Heals = "治疗"
    Locales.KeyWords.ConjuredItem = "魔法制造"
    Locales.KeyWords.Health = "生命值"
    Locales.KeyWords.Life = "life" -- TODO
    Locales.KeyWords.Damage = "生命值"
    Locales.KeyWords.Mana = "法力值"
    Locales.KeyWords.WellFed = "进食充分"
    Locales.KeyWords.OverTime = "每秒恢复"
    Locales.KeyWords.Bandage = "急救"
    Locales.KeyWords.FoodAndDrink = "remain seated while" -- TODO

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

    Locales.Patterns.HealthAndMana = {  -- TODO
        {
            pattern = "([%d,%.]+)点生命值.- ([%d,%.]+)点法力值",
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
            pattern = "在([%d%.]+)秒.-恢复.-([%d%.]+)点法力值",
            healthIndex = 2,
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
    }

    -- Export
    ns.Locales = Locales
end
