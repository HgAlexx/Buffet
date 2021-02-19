local _, ns = ...

-- Local namespace
local ConstRetail = {}

ConstRetail.ItemClasses = {}
ConstRetail.ItemClasses.Consumable = 0
ConstRetail.ItemClasses.Tradeskill = 7
ConstRetail.ItemClasses.Miscellaneous = 15

ConstRetail.ItemConsumableSubClasses = {}
ConstRetail.ItemConsumableSubClasses.Potion = 1
ConstRetail.ItemConsumableSubClasses.FoodAndDrink = 5
ConstRetail.ItemConsumableSubClasses.Bandage = 7
ConstRetail.ItemConsumableSubClasses.Other = 8

ConstRetail.ItemTradeskillSubClasses = {}
ConstRetail.ItemTradeskillSubClasses.Cooking = 8

ConstRetail.ItemMiscellaneousSubClasses = {}
ConstRetail.ItemMiscellaneousSubClasses.Reagent = 1

ConstRetail.ValidItemClasses = {
    {ConstRetail.ItemClasses.Consumable, ConstRetail.ItemConsumableSubClasses.Bandage},
    {ConstRetail.ItemClasses.Consumable, ConstRetail.ItemConsumableSubClasses.FoodAndDrink},
    {ConstRetail.ItemClasses.Consumable, ConstRetail.ItemConsumableSubClasses.Other},
    {ConstRetail.ItemClasses.Consumable, ConstRetail.ItemConsumableSubClasses.Potion},

    {ConstRetail.ItemClasses.Tradeskill, ConstRetail.ItemTradeskillSubClasses.Cooking},

    {ConstRetail.ItemClasses.Miscellaneous, ConstRetail.ItemMiscellaneousSubClasses.Reagent},
}

-- InstanceId: https://wow.gamepedia.com/InstanceID
-- uiMapId: https://wow.gamepedia.com/UiMapID
ConstRetail.Restrictions = {
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
            inInstanceIds = { 1220, 1669 }, -- Broken Isles, Argus
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
ns.ConstRetail = ConstRetail
