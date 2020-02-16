local _, ns = ...

-- Local namespace
local Const = {}

Const.DBdefaults = { macroHP = "#showtooltip\n%MACRO%", macroMP = "#showtooltip\n%MACRO%", combat = true }
Const.ItemDBdefaults = { itemCache = {}, build = 0, nextScanDelay = 1.2, version = 0 }

Const.BestCategories = {}
Const.BestCategories.bandage = "bandage"
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
