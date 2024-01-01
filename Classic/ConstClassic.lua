local _, ns = ...

-- Imports
local Utility = ns.Utility

if Utility.IsClassic then
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
        [19068] = { -- Warsong Gulch Silk Bandage
            {
                inInstanceIds = { 489 }, -- Warsong Gulch
            },
        },

        [19067] = { -- Warsong Gulch Magewave Bandage
            {
                inInstanceIds = { 489 }, -- Warsong Gulch
            },
        },
        [19066] = { -- Warsong Gulch Runecloth Bandage
            {
                inInstanceIds = { 489 }, -- Warsong Gulch
            },
        },

        [19062] = { -- Warsong Gulch Field Ration
            {
                inInstanceIds = { 489 }, -- Warsong Gulch
            },
        },
        [19061] = { -- Warsong Gulch Iron Ration
            {
                inInstanceIds = { 489 }, -- Warsong Gulch
            },
        },

        [19060] = { -- Warsong Gulch Enriched Ration
            {
                inInstanceIds = { 489 }, -- Warsong Gulch
            },
        },

        [17348] = { -- Major Healing Draught
            {
                inInstanceIds = { 30, 489 }, -- Alterac Valley, Warsong Gulch
            },
        },
        [17349] = { -- Superior Healing Draught
            {
                inInstanceIds = { 30, 489 }, -- Alterac Valley, Warsong Gulch
            },
        },
        [17351] = { -- Major Mana Draught
            {
                inInstanceIds = { 30, 489 }, -- Alterac Valley, Warsong Gulch
            },
        },
        [17352] = { -- Superior Mana Draught
            {
                inInstanceIds = { 30, 489 }, -- Alterac Valley, Warsong Gulch
            },
        },
        [17351] = { -- Major Mana Draught
            {
                inInstanceIds = { 30, 489 }, -- Alterac Valley, Warsong Gulch
            }
        },
        [17348] = { -- Major Healing Draught
            {
                inInstanceIds = { 30, 489 }, -- Alterac Valley, Warsong Gulch
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
    ns.ActiveConst = Const
end
