local _, ns = ...

if GetLocale() ~= "zhCN" then
    return
end

-- Shared by the zhCN locale selectors for each game version.
-- Bump this when parsing changes so previously saved results are rescanned.
local Locales = { ParserVersion = 1 }
Locales.ThousandSeparator = ","
Locales.KeyWords = {
    Use = "使用",
    Restores = { "恢复", "回复" },
    Heals = { "恢复", "回复", "治疗" },
    ConjuredItem = { "魔法制造", "魔法物品", "魔法宝石" },
    Health = "生命值",
    Life = "生命",
    Damage = { "生命值", "伤害" },
    Mana = "法力值",
    -- "恢复" alone also occurs on ordinary food, water and potions.
    WellFed = { "进食充分", "花费至少" },
    OverTime = { "每秒恢复", "每秒回复", "每1秒恢复", "每1秒回复" },
    Bandage = "急救",
    FoodAndDrink = "必须保持坐姿",
    QuietContemplation = "静默省思",
}

Locales.Patterns = {
    OverTime = {
        "持续%s*([%d%.]+)%s*秒",
        "在%s*([%d%.]+)%s*秒内",
    },
    Bandage = {},
    HealthAndMana = {},
    Health = {},
    Mana = {},
}

local function AddPattern(list, pattern, healthIndex, manaIndex, pct)
    list[#list + 1] = {
        pattern = pattern,
        healthIndex = healthIndex,
        manaIndex = manaIndex,
        pct = pct or false,
    }
end

-- Match ranges before single amounts so a potion uses its average, not its
-- upper bound. Keep Chinese words outside character classes: Lua matches bytes.
local number = "([%d,%.]+)"
local percent = "([%d%.]+)%%%s*"
local amounts = {
    { pattern = number .. "%s*至%s*" .. number .. "%s*点", index = { 1, 2 }, count = 2 },
    { pattern = number .. "%s*到%s*" .. number .. "%s*点", index = { 1, 2 }, count = 2 },
    { pattern = number .. "%s*点", index = 1, count = 1 },
}

local function OffsetIndex(index, offset)
    if type(index) == "table" then
        return { index[1] + offset, index[2] + offset }
    end
    return index + offset
end

local function AddResourcePatterns(list, resource, isHealth)
    -- Both "20%的生命值" and "总生命值的20%" occur in Chinese tooltips.
    AddPattern(list, percent .. "的%s*" .. resource, isHealth and 1 or nil, not isHealth and 1 or nil, true)
    AddPattern(list, resource .. "的%s*" .. percent, isHealth and 1 or nil, not isHealth and 1 or nil, true)

    for _, amount in ipairs(amounts) do
        AddPattern(list, amount.pattern .. resource,
            isHealth and amount.index or nil, not isHealth and amount.index or nil)
    end
end

AddResourcePatterns(Locales.Patterns.Health, "生命值", true)
AddResourcePatterns(Locales.Patterns.Mana, "法力值", false)
-- Older healthstone descriptions can use "生命" instead of "生命值".
AddResourcePatterns(Locales.Patterns.Health, "生命", true)

AddPattern(Locales.Patterns.Bandage, number .. "%s*点生命值", 1)
AddPattern(Locales.Patterns.Bandage, number .. "%s*点伤害", 1)

local combined = Locales.Patterns.HealthAndMana
for _, order in ipairs({
    { first = "生命值", second = "法力值", healthFirst = true },
    { first = "法力值", second = "生命值", healthFirst = false },
}) do
    local first, second = order.first, order.second
    local healthIndex = order.healthFirst and 1 or 2
    local manaIndex = order.healthFirst and 2 or 1

    -- Different percentages for the two resources.
    AddPattern(combined, percent .. "的%s*" .. first .. "[^%d%%]*" .. percent .. "的%s*" .. second,
        healthIndex, manaIndex, true)
    AddPattern(combined, first .. "的%s*" .. percent .. "[^%d%%]*" .. second .. "的%s*" .. percent,
        healthIndex, manaIndex, true)

    -- Separate absolute amounts or ranges, in either resource order.
    for _, firstAmount in ipairs(amounts) do
        for _, secondAmount in ipairs(amounts) do
            local firstIndex = firstAmount.index
            local secondIndex = OffsetIndex(secondAmount.index, firstAmount.count)
            AddPattern(combined, firstAmount.pattern .. first .. "[^%d%%]*" .. secondAmount.pattern .. second,
                order.healthFirst and firstIndex or secondIndex,
                order.healthFirst and secondIndex or firstIndex)
        end
    end

    -- One shared value: "回复1440至1760点法力值和生命值" or
    -- "每秒恢复你最大生命值和法力值的6%".
    -- Require a conjunction rather than skipping over a second numeric value.
    for _, conjunction in ipairs({ "和", "及" }) do
        local resources = first .. "%s*" .. conjunction .. "%s*" .. second
        AddPattern(combined, percent .. "的%s*" .. resources, 1, 1, true)
        AddPattern(combined, resources .. "的%s*" .. percent, 1, 1, true)
        for _, amount in ipairs(amounts) do
            AddPattern(combined, amount.pattern .. resources, amount.index, amount.index)
        end
    end
end

ns.ZhCNItemLocales = Locales
