local _, ns = ...

--[[
    Special char must be escaped for:
    - ThousandSeparator
    - Patterns
--]]

-- Imports
local Utility = ns.Utility

if Utility.IsRetail and GetLocale() == "zhCN" then
    -- Local namespace
    local Locales = {}

    Locales.ThousandSeparator = ","

    Locales.KeyWords = {}
    Locales.KeyWords.Use = "使用"
    Locales.KeyWords.Restores = "恢复"
    Locales.KeyWords.Heals = "治疗"
    Locales.KeyWords.ConjuredItem = "魔法制造"
    Locales.KeyWords.Health = "生命值"
    Locales.KeyWords.Damage = "生命值"
    Locales.KeyWords.Mana = "法力值"
    Locales.KeyWords.WellFed = "进食充分"
    Locales.KeyWords.OverTime = "每秒恢复"

    Locales.Patterns = {}
    Locales.Patterns.OverTime = "持续(%d+)秒"

    Locales.Patterns.Bandage = {
        {
            pattern = "([%d,%.]+)点生命值",
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
            pattern = "([%d%.]+)%%的生命值.- ([%d%.]+)%%的法力值",
            healthIndex = 1,
            manaIndex = 2,
            pct = true
        },
        {
            pattern = "([%d,%.]+)点生命值.- ([%d,%.]+)点法力值",
            healthIndex = 1,
            manaIndex = 2,
            pct = false
        },
    }

    Locales.Patterns.Health = {
        {
            pattern = "([%d%.]+)%%的生命值",
            healthIndex = 1,
            manaIndex = nil,
            pct = true
        },
        {
            pattern = "([%d,%.]+)点生命值",
            healthIndex = 1,
            manaIndex = nil,
            pct = false
        },
    }

    Locales.Patterns.Mana = {
        {
            pattern = "([%d%.]+)%%的法力值",
            healthIndex = nil,
            manaIndex = 1,
            pct = true
        },
        {
            pattern = "([%d,%.]+)点法力值",
            healthIndex = nil,
            manaIndex = 1,
            pct = false
        },
    }

    -- Export
    ns.Locales = Locales
end
