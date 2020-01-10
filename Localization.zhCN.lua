--[[
    Special char must be escaped for:
    - ThousandSeparator
    - Patterns
--]]
if GetLocale() == "zhCN" then
    ThousandSeparator = ","

    KeyWords.Use = "使用"
    KeyWords.Restores = "恢复"
    KeyWords.Heals = "治疗"
    KeyWords.ConjuredItem = "魔法制造"
    KeyWords.Health = "生命值"
    KeyWords.Damage = "生命值"
    KeyWords.Mana = "法力值"
    KeyWords.WellFed = "进食充分"
    KeyWords.OverTime = "每秒恢复"

    Patterns.FlatHealth = "([%d,%.]+)点生命值"
    Patterns.FlatDamage = "([%d,%.]+)点生命值"
    Patterns.FlatMana = "([%d,%.]+)点法力值"
    Patterns.PctHealth = "([%d%.]+)%%的生命值"
    Patterns.PctMana = "([%d%.]+)%%的法力值"
    Patterns.OverTime = "持续(%d+)秒"

    -- Classic stuff
    Classic_KeyWords.Bandage = "急救"
    Classic_Patterns.Bandage = "在([%d%.]+)秒.-恢复.-([%d%.]+)点生命值"
    Classic_Patterns.Food = "在([%d%.]+)秒.-恢复.-([%d%.]+)点生命值"
    Classic_Patterns.Drink = "在([%d%.]+)秒.-恢复.-([%d%.]+)点法力值"
    Classic_Patterns.HealthPotion = "([%d%.]+)到([%d%.]+)点生命值"
    Classic_Patterns.ManaPotion = "([%d%.]+)到([%d%.]+)点法力值"

    --ItemType.Consumable = "Verbrauchbares"
    --
    --ItemSubType.Bandage = "Verband"
    --ItemSubType.Consumable = "Verbrauchbares"
    --ItemSubType.FoodAndDrink = "Speis & Trank"
    --ItemSubType.Other = "Anderes"
    --ItemSubType.Potion = "Trank"
end
