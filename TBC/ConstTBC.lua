local _, ns = ...

-- Local namespace
local ConstTBC = {}

ConstTBC.ItemClasses = {}
ConstTBC.ItemClasses.Consumable = 0
ConstTBC.ItemClasses.Tradeskill = 7
ConstTBC.ItemClasses.Miscellaneous = 15

ConstTBC.ItemConsumableSubClasses = {}
ConstTBC.ItemConsumableSubClasses.Potion = 1
ConstTBC.ItemConsumableSubClasses.FoodAndDrink = 5
ConstTBC.ItemConsumableSubClasses.Bandage = 7
ConstTBC.ItemConsumableSubClasses.Other = 8

ConstTBC.ItemTradeskillSubClasses = {}
ConstTBC.ItemTradeskillSubClasses.Cooking = 8

ConstTBC.ItemMiscellaneousSubClasses = {}
ConstTBC.ItemMiscellaneousSubClasses.Reagent = 1

ConstTBC.ValidItemClasses = {
    {ConstTBC.ItemClasses.Consumable, ConstTBC.ItemConsumableSubClasses.Bandage},
    {ConstTBC.ItemClasses.Consumable, ConstTBC.ItemConsumableSubClasses.FoodAndDrink},
    {ConstTBC.ItemClasses.Consumable, ConstTBC.ItemConsumableSubClasses.Other},
    {ConstTBC.ItemClasses.Consumable, ConstTBC.ItemConsumableSubClasses.Potion},

    {ConstTBC.ItemClasses.Tradeskill, ConstTBC.ItemTradeskillSubClasses.Cooking},

    {ConstTBC.ItemClasses.Miscellaneous, ConstTBC.ItemMiscellaneousSubClasses.Reagent},
}

-- InstanceId: https://wow.gamepedia.com/InstanceID
-- uiMapId: https://wow.gamepedia.com/UiMapID/Classic
ConstTBC.Restrictions = {
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
ns.ConstTBC = ConstTBC
