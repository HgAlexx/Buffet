local _, ns = ...

-- Local namespace
local Const = {}

Const.DBdefaults = {
    macroHP = "#showtooltip\n%MACRO%",
    macroMP = "#showtooltip\n%MACRO%",
    combat = true,
    modConjured = "mod:shift",
    modSpecial = "mod:ctrl",
    consModConjured = "mod:shift",
    consModSpecial = "mod:ctrl"
}

Const.MacroNames = {
    defaultHP = "AutoHP",
    defaultMP = "AutoMP",
    foodOnlyHP = "FoodOnlyHP",
    drinkOnlyMP = "DrinkOnlyMP",
    consumableHP = "ConsumableHP",
    consumableMP = "ConsumableMP"
}

Const.ItemDBdefaults = { itemCache = {}, build = 0, nextScanDelay = 1.2, version = 0 }

Const.BestCategories = {}
Const.BestCategories.bandage = "bandage"
Const.BestCategories.rune = "rune"
Const.BestCategories.hppot = "hppot"
Const.BestCategories.mppot = "mppot"
Const.BestCategories.healthstone = "healthstone"
Const.BestCategories.managem = "managem"
Const.BestCategories.water = "water"
Const.BestCategories.food = "food"
Const.BestCategories.percfood = "percfood"
Const.BestCategories.percwater = "percwater"

-- Export
ns.Const = Const
