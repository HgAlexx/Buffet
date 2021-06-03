local _, ns = ...

-- Local namespace
local Const = {}

-- unused for classic, but we keep it here in case class ids are implemented in the future
Const.ItemClasses = {}
Const.ItemClasses.Consumable = 0

Const.ItemConsumableSubClasses = {}
Const.ItemConsumableSubClasses.Bandage = 0
Const.ItemConsumableSubClasses.FoodAndDrink = 0
Const.ItemConsumableSubClasses.Potion = 0

Const.ValidItemClasses = {
    { Const.ItemClasses.Consumable, Const.ItemConsumableSubClasses.Bandage},
    { Const.ItemClasses.Consumable, Const.ItemConsumableSubClasses.FoodAndDrink},
    { Const.ItemClasses.Consumable, Const.ItemConsumableSubClasses.Potion},
}

-- InstanceId: https://wow.gamepedia.com/InstanceID
-- uiMapId: https://wow.gamepedia.com/UiMapID/Classic
Const.Restrictions = {
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
ns.ConstClassic = Const
