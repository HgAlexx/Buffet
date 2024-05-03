local _, ns = ...

-- Imports
local Utility = ns.Utility
local Const = ns.Const

if Utility.IsCataclysm then
    -- Local namespace
    local ActiveConst = {}

    ActiveConst.ItemClasses = {}
    ActiveConst.ItemClasses.Consumable = 0
    ActiveConst.ItemClasses.Armor = 4
    ActiveConst.ItemClasses.Tradeskill = 7
    ActiveConst.ItemClasses.Miscellaneous = 15

    ActiveConst.ItemConsumableSubClasses = {}
    ActiveConst.ItemConsumableSubClasses.ExplosivesAndDevices = 0
    ActiveConst.ItemConsumableSubClasses.Potion = 1
    ActiveConst.ItemConsumableSubClasses.FoodAndDrink = 5
    ActiveConst.ItemConsumableSubClasses.Bandage = 7
    ActiveConst.ItemConsumableSubClasses.Other = 8

    ActiveConst.ItemArmorSubClasses = {}
    ActiveConst.ItemArmorSubClasses.Miscellaneous = 0

    ActiveConst.ItemTradeskillSubClasses = {}
    ActiveConst.ItemTradeskillSubClasses.Cooking = 8

    ActiveConst.ItemMiscellaneousSubClasses = {}
    ActiveConst.ItemMiscellaneousSubClasses.Reagent = 1

    ActiveConst.ValidItemClasses = {
        { ActiveConst.ItemClasses.Consumable, ActiveConst.ItemConsumableSubClasses.ExplosivesAndDevices},
        { ActiveConst.ItemClasses.Consumable, ActiveConst.ItemConsumableSubClasses.Bandage},
        { ActiveConst.ItemClasses.Consumable, ActiveConst.ItemConsumableSubClasses.FoodAndDrink},
        { ActiveConst.ItemClasses.Consumable, ActiveConst.ItemConsumableSubClasses.Other},
        { ActiveConst.ItemClasses.Consumable, ActiveConst.ItemConsumableSubClasses.Potion},

        { ActiveConst.ItemClasses.Armor, ActiveConst.ItemArmorSubClasses.Miscellaneous},

        { ActiveConst.ItemClasses.Tradeskill, ActiveConst.ItemTradeskillSubClasses.Cooking},

        { ActiveConst.ItemClasses.Miscellaneous, ActiveConst.ItemMiscellaneousSubClasses.Reagent},
    }

    ActiveConst.StaticItemData = {
        [32903] = { -- Cenarion Mana Salve
            isPotion = true,
            isMana = true
        },
        [32904] = { -- Cenarion Healing Salve
            isPotion = true,
            isHealth = true
        },
        [33092] = { -- Healing Potion Injector
            isPotion = true,
            isHealth = true
        },
        [33093] = { -- Mana Potion Injector
            isPotion = true,
            isMana = true
        },
        [41166] = { -- Runic Healing Injector
            modifiers = {
                {
                    healthFactor = 1.25,
                    conditions = {
                        {
                            profession = 202 -- TradeSkillLineID: engineer
                        }
                    }
                }
            }
        },
        [42545] = { -- Runic Mana Injector
            modifiers = {
                {
                    manaFactor = 1.25,
                    conditions = {
                        {
                            profession = 202 -- TradeSkillLineID: engineer
                        }
                    }
                }
            }
        }
    }

    -- InstanceId: https://wow.gamepedia.com/InstanceID
    -- uiMapId: https://wow.gamepedia.com/UiMapID
    ActiveConst.Restrictions = {
        [19307] = { -- Alterac Heavy Runecloth Bandage
            {
                inInstanceIds = { 30 }, -- Alterac Valley
            },
        },
        [19066] = { -- Warsong Gulch Runecloth Bandage
            {
                inInstanceIds = { 489 }, -- Warsong Gulch
            },
        },

        [17349] = { -- Superior Healing Draught
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

        [20064] = { -- Arathi Basin Iron Ration
            {
                inInstanceIds = { 2107 }, -- Arathi Basin
            },
        },
        [20063] = { -- Arathi Basin Field Ration
            {
                inInstanceIds = { 2107 }, -- Arathi Basin
            },
        },
        [20062] = { -- Arathi Basin Enriched Ration
            {
                inInstanceIds = { 2107 }, -- Arathi Basin
            },
        },

        [17348] = { -- Major Healing Draught
            {
                inInstanceIds = { 30, 489, 2107 }, -- Alterac Valley, Warsong Gulch, Arathi Basin
            },
        },
        [17349] = { -- Superior Healing Draught
            {
                inInstanceIds = { 30, 489, 2107 }, -- Alterac Valley, Warsong Gulch, Arathi Basin
            },
        },
        [17351] = { -- Major Mana Draught
            {
                inInstanceIds = { 30, 489, 2107 }, -- Alterac Valley, Warsong Gulch, Arathi Basin
            },
        },
        [17352] = { -- Superior Mana Draught
            {
                inInstanceIds = { 30, 489, 2107 }, -- Alterac Valley, Warsong Gulch, Arathi Basin
            },
        },
        [17351] = { -- Major Mana Draught
            {
                inInstanceIds = { 30, 489, 2107 }, -- Alterac Valley, Warsong Gulch, Arathi Basin
            }
        },
        [17348] = { -- Major Healing Draught
            {
                inInstanceIds = { 30, 489, 2107 }, -- Alterac Valley, Warsong Gulch, Arathi Basin
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
    ns.ActiveConst = ActiveConst
end
