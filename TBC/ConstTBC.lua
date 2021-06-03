local _, ns = ...

-- Local namespace
local Const = {}

Const.ItemClasses = {}
Const.ItemClasses.Consumable = 0
Const.ItemClasses.Tradeskill = 7
Const.ItemClasses.Miscellaneous = 15

Const.ItemConsumableSubClasses = {}
Const.ItemConsumableSubClasses.ExplosivesAndDevices = 0
Const.ItemConsumableSubClasses.Potion = 1
Const.ItemConsumableSubClasses.FoodAndDrink = 5
Const.ItemConsumableSubClasses.Bandage = 7
Const.ItemConsumableSubClasses.Other = 8

Const.ItemTradeskillSubClasses = {}
Const.ItemTradeskillSubClasses.Cooking = 8

Const.ItemMiscellaneousSubClasses = {}
Const.ItemMiscellaneousSubClasses.Reagent = 1

Const.ValidItemClasses = {
    { Const.ItemClasses.Consumable, Const.ItemConsumableSubClasses.ExplosivesAndDevices},
    { Const.ItemClasses.Consumable, Const.ItemConsumableSubClasses.Bandage},
    { Const.ItemClasses.Consumable, Const.ItemConsumableSubClasses.FoodAndDrink},
    { Const.ItemClasses.Consumable, Const.ItemConsumableSubClasses.Other},
    { Const.ItemClasses.Consumable, Const.ItemConsumableSubClasses.Potion},

    { Const.ItemClasses.Tradeskill, Const.ItemTradeskillSubClasses.Cooking},

    { Const.ItemClasses.Miscellaneous, Const.ItemMiscellaneousSubClasses.Reagent},
}

-- InstanceId: https://wow.gamepedia.com/InstanceID
-- uiMapId: https://wow.gamepedia.com/UiMapID
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

    [32902] = { -- Bottled Nethergon Energy
        {
            inInstanceIds = { 550, 552, 553, 554, }, -- Tempest Keep instances
        },
    },
    [32905] = { -- Bottled Nethergon Vapor
        {
            inInstanceIds = { 550, 552, 553, 554, }, -- Tempest Keep instances
        },
    },

    [32903] = { -- Cenarion Mana Salve
        {
            inInstanceIds = { 545, 546, 547, 548, }, -- Coilfang instances
        },
    },
    [32904] = { -- Cenarion Healing Salve
        {
            inInstanceIds = { 545, 546, 547, 548, }, -- Coilfang instances
        },
    },

    [32783] = { -- Blue Ogre Brew
        {
            inSubZones = { "Bash'ir Landing", "Crystal Spine", "Furywing's Perch", "Insidion's Perch", "Forge Camp: Wrath", "Skyguard Outpost", "Ogri'la", "Obsidia's Perch", "Rivendark's Perch", "Forge Camp: Terror" }, -- Blade's Edge Plateaus
        },
    },
    [32784] = { -- Red Ogre Brew
        {
            inSubZones = { "Bash'ir Landing", "Crystal Spine", "Furywing's Perch", "Insidion's Perch", "Forge Camp: Wrath", "Skyguard Outpost", "Ogri'la", "Obsidia's Perch", "Rivendark's Perch", "Forge Camp: Terror" }, -- Blade's Edge Plateaus
        },
    },

    [32909] = { -- Blue Ogre Brew Special
        {
            inSubZones = { "Bash'ir Landing", "Crystal Spine", "Furywing's Perch", "Insidion's Perch", "Forge Camp: Wrath", "Skyguard Outpost", "Ogri'la", "Obsidia's Perch", "Rivendark's Perch", "Forge Camp: Terror" }, -- Blade's Edge Plateaus
        },
    },
    [32910] = { -- Red Ogre Brew Special
        {
            inSubZones = { "Bash'ir Landing", "Crystal Spine", "Furywing's Perch", "Insidion's Perch", "Forge Camp: Wrath", "Skyguard Outpost", "Ogri'la", "Obsidia's Perch", "Rivendark's Perch", "Forge Camp: Terror" }, -- Blade's Edge Plateaus
        },
    },

    [63144] = { -- Baradin's Wardens Healing Potion
        {
            inInstanceIds = { 1630 }, -- Tol Barad
        },
    },
    [63145] = { -- Baradin's Wardens Mana Potion
        {
            inInstanceIds = { 1630 }, -- Tol Barad
        },
    },

    [64993] = { -- Hellscream's Reach Mana Potion
        {
            inInstanceIds = { 1630 }, -- Tol Barad
        },
    },
    [64994] = { -- Hellscream's Reach Healing Potion
        {
            inInstanceIds = { 1630 }, -- Tol Barad
        },
    },

    [140352] = { -- Dreamberries
        {
            matchMode = "all",
            inInstanceIds = { 1220 }, -- Broken Isles
            inInstanceTypes = { "none" },
        },
        {
            matchMode = "all",
            inInstanceIds = { 1669 }, -- Argus
            inInstanceTypes = { "none" },
        },
    },

    [174351] = { -- K’Bab
        {
            inInstanceIds = { },
        },
    },

    [138486] = { -- Third wind potion
        {
            pvp = { bg = true, brawl = true }
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
ns.ConstTBC = Const
