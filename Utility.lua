local _, ns = ...

-- Local namespace
local Utility = {}
local addonName = "Buffet"
local coloredAddonName = "|cFF33FF99" .. addonName .. "|r:"
local debugColoredAddonName = "|cFF33BB99" .. addonName .. "|r:"


-- Localize functions
local string_match = string.match
local string_find = string.find
local string_lower = string.lower

-- Parameters
do
    Utility.DebugStatus = false
    --@debug@
    Utility.DebugStatus = true
    --@end-debug@

    Utility.buffetTooltip = nil
    Utility.Mode = 1

    Utility.IsClassic = false
    Utility.IsTBC = false
    Utility.IsWLK = false
    Utility.IsCataclysm = false
    Utility.IsRetail = false

    local _, _, _, interfaceVersion = GetBuildInfo()
    if interfaceVersion >= 10000 and interfaceVersion < 20500 then
        Utility.IsClassic = true
    elseif interfaceVersion >= 20500 and interfaceVersion < 30000 then
        Utility.IsTBC = true
    elseif interfaceVersion >= 30000 and interfaceVersion < 40000 then
        Utility.IsWLK = true
    elseif interfaceVersion >= 40000 and interfaceVersion < 50000 then
        Utility.IsCataclysm = true
    elseif interfaceVersion >= 90000 then
        Utility.IsRetail = true
    end

    Utility.skillLineIds = {}
end

function Utility.GetTime()
    return (debugprofilestop() / 1000)
end

function Utility.Print(...)
    if Utility.Mode == 2 then
        print(coloredAddonName, ...)
    else
        DEFAULT_CHAT_FRAME:AddMessage(string.join(" ", coloredAddonName, ...))
    end
end

function Utility.Debug(...)
    --@debug@
    if not Utility.DebugStatus then
        return
    end

    if Utility.Mode == 2 then
        print(debugColoredAddonName, ...)
    else
        local arg = {...}
        local t = ""
        for i, v in ipairs(arg) do
            if type(v) == "table" then
                for k, w in pairs(v) do
                    t = t .. ", " .. k .. "=" .. tostring(w)
                end
            else
                t = t .. " " .. tostring(v)
            end
        end
        DEFAULT_CHAT_FRAME:AddMessage(debugColoredAddonName .. t)
    end
    --@end-debug@
end

function Utility.BoolToStr(value)
    if value then
        return "Yes"
    end
    return "No"
end

function Utility.Trim(s)
    return string_match(s,'^()%s*$') and '' or string_match(s,'^%s*(.*%S)')
end

function Utility.StringContains(string, needle)
    if string and needle then
        local found = string_find(string, needle, 1, true)
        if found == nil then
            return false
        end
        return true
    end
    return false
end

function Utility.TableCount(table)
    local c = 0
    if table then
        for _, v in pairs(table) do
            if v then
                c = c + 1
            end
        end
    end
    return c
end

function Utility.TableContainsKey(table, key)
    if table then
        for k, _ in pairs(table) do
            if k == key then
                return true
            end
        end
    end
    return false
end

function Utility.TableContainsValue(table, value)
    if table then
        for _, v in pairs(table) do
            if v == value then
                return true
            end
        end
    end
    return false
end

function Utility.GetTooltip()
    local tooltip = Utility.buffetTooltip or CreateFrame("GameToolTip", "buffetTooltip", nil, "GameTooltipTemplate")
    tooltip:SetOwner(WorldFrame, "ANCHOR_NONE")
    tooltip:ClearLines()
    return tooltip
end


function Utility.IsPlayerInInstanceId(ids)
    local _,_,_,_,_,_,_,instanceId = GetInstanceInfo()
    if instanceId then
        for _,v in pairs(ids) do
            if v == instanceId then
                return true
            end
        end
    end
    return false
end

function Utility.IsPlayerInInstanceType(types)
    local _,instanceType, diffId = GetInstanceInfo()
    instanceType = instanceType or "none"
    for _,v in pairs(types) do
        if (v == "none" and diffId == 0 and instanceType ~= "pvp" and instanceType ~= "arena") then
            return true
        end
        if (v == instanceType) then
            return true
        end
    end
    return false
end

function Utility.IsPlayerInMapId(ids)
    local uiMapId = C_Map.GetBestMapForUnit("player");
    if uiMapId then
        repeat
            for _,v in pairs(ids) do
                if v == uiMapId then
                    return true
                end
            end
            local mapInfo = C_Map.GetMapInfo(uiMapId);
            uiMapId = mapInfo and mapInfo.parentMapID or 0;
        until uiMapId == 0;
    end
    return false
end

function Utility.IsPlayerInSubZoneName(names)
    local currentSubZone = string_lower(GetSubZoneText())
    if currentSubZone ~= "" then
        local babbleSubZone = LibStub("LibBabble-SubZone-3.0"):GetUnstrictLookupTable();
        for k,v in pairs(names) do
            local subZone = babbleSubZone[v] -- get locale subzone name from LibBabble
            if subZone and (subZone:lower() == currentSubZone) then
                return true
            end
        end
    end
    return false
end

function Utility.ShowPlayerZoneInfo()
    local uiMapId = C_Map.GetBestMapForUnit("player");
    if uiMapId then
        repeat
            Utility.Debug("uiMapId=" .. uiMapId)
            local mapInfo = C_Map.GetMapInfo(uiMapId);
            uiMapId = mapInfo and mapInfo.parentMapID or 0;
        until uiMapId == 0;
    end

    local _,instanceType,diffId,_,_,_,_,instanceId = GetInstanceInfo()
    instanceType = instanceType or "none"
    if instanceId then
        Utility.Debug("instanceId=" .. instanceId)
        Utility.Debug("instanceType=" .. instanceType)
        Utility.Debug("diffId=" .. diffId)
    end

    local currentSubZone = string_lower(GetSubZoneText())
    if currentSubZone ~= "" then
        local babbleSubZone = LibStub("LibBabble-SubZone-3.0"):GetUnstrictLookupTable();
        for k, v in pairs(babbleSubZone) do
            local subZone = v -- get locale subzone name from LibBabble
            if subZone and (subZone:lower() == currentSubZone) then
                Utility.Debug("currentSubZone=" .. currentSubZone .. ", EN=" .. k)
                return
            end
        end
    end
end

function Utility.LoadProfessions()
    if not Utility.IsRetail then
        -- from https://www.wowinterface.com/forums/showthread.php?t=57554
        local profNames = Utility.ProfessionNames[GetLocale()]
        local profNames_rev = tInvert(profNames)

        for i = 1, GetNumSkillLines() do
            local name = GetSkillLineInfo(i)
            if profNames_rev[name] then
                table.insert(Utility.skillLineIds, profNames_rev[name])
            end
        end
    end
    if Utility.IsRetail then
        Utility.skillLineIds = C_TradeSkillUI.GetAllProfessionTradeSkillLines()
    end
end

-- from https://www.wowinterface.com/forums/showthread.php?t=57554
Utility.ProfessionNames = {
    enUS = {
        [164] = "Blacksmithing",
        [165] = "Leatherworking",
        [171] = "Alchemy",
        [182] = "Herbalism",
        [185] = "Cooking",
        [186] = "Mining",
        [197] = "Tailoring",
        [202] = "Engineering",
        [333] = "Enchanting",
        [356] = "Fishing",
        [393] = "Skinning",
        [755] = "Jewelcrafting",
        [773] = "Inscription",
    },
    deDE = {
        [164] = "Schmiedekunst",
        [165] = "Lederverarbeitung",
        [171] = "Alchemie",
        [182] = "Kräuterkunde",
        [185] = "Kochkunst",
        [186] = "Bergbau",
        [197] = "Schneiderei",
        [202] = "Ingenieurskunst",
        [333] = "Verzauberkunst",
        [356] = "Angeln",
        [393] = "Kürschnerei",
        [755] = "Juwelierskunst",
        [773] = "Inschriftenkunde",
    },
    frFR = {
        [164] = "Forge",
        [165] = "Travail du cuir",
        [171] = "Alchimie",
        [182] = "Herboristerie",
        [185] = "Cuisine",
        [186] = "Minage",
        [197] = "Couture",
        [202] = "Ingénierie",
        [333] = "Enchantement",
        [356] = "Pêche",
        [393] = "Dépeçage",
        [755] = "Joaillerie",
        [773] = "Calligraphie",
    },
    esMX = {
        [164] = "Herrería",
        [165] = "Peletería",
        [171] = "Alquimia",
        [182] = "Herboristería",
        [185] = "Cocina",
        [186] = "Minería",
        [197] = "Sastrería",
        [202] = "Ingeniería",
        [333] = "Encantamiento",
        [356] = "Pesca",
        [393] = "Desuello",
        [755] = "Joyería",
        [773] = "Inscripción",
    },
    ptBR = {
        [164] = "Ferraria",
        [165] = "Couraria",
        [171] = "Alquimia",
        [182] = "Herborismo",
        [185] = "Culinária",
        [186] = "Mineração",
        [197] = "Alfaiataria",
        [202] = "Engenharia",
        [333] = "Encantamento",
        [356] = "Pesca",
        [393] = "Esfolamento",
        [755] = "Joalheria",
        [773] = "Escrivania",
    },
    ruRU = {
        [164] = "Кузнечное дело",
        [165] = "Кожевничество",
        [171] = "Алхимия",
        [182] = "Травничество",
        [185] = "Кулинария",
        [186] = "Горное дело",
        [197] = "Портняжное дело",
        [202] = "Инженерное дело",
        [333] = "Наложение чар",
        [356] = "Рыбная ловля",
        [393] = "Снятие шкур",
        [755] = "Ювелирное дело",
        [773] = "Начертание",
    },
    zhCN = {
        [164] = "锻造",
        [165] = "制皮",
        [171] = "炼金术",
        [182] = "草药学",
        [185] = "烹饪",
        [186] = "采矿",
        [197] = "裁缝",
        [202] = "工程学",
        [333] = "附魔",
        [356] = "钓鱼",
        [393] = "剥皮",
        [755] = "珠宝加工",
        [773] = "铭文",
    },
    zhTW = {
        [164] = "鍛造",
        [165] = "製皮",
        [171] = "鍊金術",
        [182] = "草藥學",
        [185] = "烹飪",
        [186] = "採礦",
        [197] = "裁縫",
        [202] = "工程學",
        [333] = "附魔",
        [356] = "釣魚",
        [393] = "剝皮",
        [755] = "珠寶設計",
        [773] = "銘文學",
    },
    koKR = {
        [164] = "대장기술",
        [165] = "가죽세공",
        [171] = "연금술",
        [182] = "약초채집",
        [185] = "요리",
        [186] = "채광",
        [197] = "재봉술",
        [202] = "기계공학",
        [333] = "마법부여",
        [356] = "낚시",
        [393] = "무두질",
        [755] = "보석세공",
        [773] = "주문각인",
    },
}

-- Export
ns.Utility = Utility
