local _, ns = ...

-- Local namespace
local ConstClassic = {}

-- unused for classic, but we keep it here in case class ids are implemented in the future
ConstClassic.ItemClasses = {}
ConstClassic.ItemClasses.Consumable = 0

ConstClassic.ItemConsumableSubClasses = {}
ConstClassic.ItemConsumableSubClasses.Bandage = 0
ConstClassic.ItemConsumableSubClasses.FoodAndDrink = 0
ConstClassic.ItemConsumableSubClasses.Potion = 0

ConstClassic.ValidItemClasses = {
    {ConstClassic.ItemClasses.Consumable, ConstClassic.ItemConsumableSubClasses.Bandage},
    {ConstClassic.ItemClasses.Consumable, ConstClassic.ItemConsumableSubClasses.FoodAndDrink},
    {ConstClassic.ItemClasses.Consumable, ConstClassic.ItemConsumableSubClasses.Potion},
}

-- InstanceId: https://wow.gamepedia.com/InstanceID
-- uiMapId: https://wow.gamepedia.com/UiMapID/Classic
ConstClassic.Restrictions = {
    [19307] = { -- Alterac Heavy Runecloth Bandage
        {
            inInstanceIds = { 30 }, -- Alterac Valley
        },
    },
    [19066] = { -- Warsong Gulch Runecloth Bandage
        {
            inInstaceIds = { 489 }, -- Warsong Gulch
        },
    },

    [17349] = { -- Superior Healing Draught
        {
            inInstaceIds = { 30, 489 }, -- Alterac Valley, Warsong Gulch
        },
    },
    [17352] = { -- Superior Mana Draught
        {
            inInstaceIds = { 30, 489 }, -- Alterac Valley, Warsong Gulch
        },
    },
    [17351] = { -- Major Mana Draught
        {
            inInstaceIds = { 30, 489 }, -- Alterac Valley, Warsong Gulch
        }
    },
    [17348] = { -- Major Healing Draught
        {
            inInstaceIds = { 30, 489 }, -- Alterac Valley, Warsong Gulch
        },
    },

    [12662] = { -- demonic rune
        {
            inInstanceIds = { }
        },
    },
    [20520] = { -- dark rune
        {
            inInstanceIds = { }
        },
    },
}

-- Export
ns.ConstClassic = ConstClassic
