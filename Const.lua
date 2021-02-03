local _, ns = ...

-- Local namespace
local Const = {}

Const.DBdefaults = {
    macroHP = "#showtooltip\n%MACRO%",
    macroMP = "#showtooltip\n%MACRO%",
    combat = true,
    hearthstone = true,
    wellFed = false,
    modPotion = "",
    modConjured = "mod:shift",
    modSpecial = "mod:ctrl",
    consModPotion = "",
    consModConjured = "mod:shift",
    consModSpecial = "mod:ctrl",
}

Const.MacroNames = {
    defaultHP = "AutoHP",
    defaultMP = "AutoMP",
    foodOnlyHP = "FoodOnlyHP",
    drinkOnlyMP = "DrinkOnlyMP",
    consumableHP = "ConsumableHP",
    consumableMP = "ConsumableMP"
}

Const.ItemDBdefaults = { itemCache = {}, build = 0, nextScanDelay = 1.2, version = 0, customMacros = {} }

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
Const.BestCategories.wellfedfood = "wellfedfood"
Const.BestCategories.wellfedwater = "wellfedwater"

Const.newMacroSource = [[local bests, cache = ... -- Keep this

-- Available categories: contains the item id or nil
-- bests.bandage
-- bests.rune
-- bests.conjuredFood
-- bests.conjuredDrink
-- bests.food
-- bests.drink
-- bests.wellFedFood
-- bests.wellFedDrink
-- bests.healthstone
-- bests.manaGem
-- bests.healthPotion
-- bests.manaPotion

-- Example for best food with default to hearthstone
local bestfood = bests.conjuredFood or bests.food or 6948

-- Must return: body [, icon]
return "#showtooltip\n/cast item:" .. bestfood, "INV_Misc_QuestionMark"]]

-- Export
ns.Const = Const
