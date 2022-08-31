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
    Utility.DebugStatus = true

    Utility.buffetTooltip = nil
    Utility.Mode = 1

    Utility.IsClassic = false
    Utility.IsTBC = false
    Utility.IsWLK = false
    Utility.IsRetail = false

    local _, _, _, interfaceVersion = GetBuildInfo()
    if interfaceVersion >= 10000 and interfaceVersion < 20500 then
        Utility.IsClassic = true
    elseif interfaceVersion >= 20500 and interfaceVersion < 30000 then
        Utility.IsTBC = true
    elseif interfaceVersion >= 30000 and interfaceVersion < 40000 then
        Utility.IsWLK = true
    elseif interfaceVersion >= 90000 then
        Utility.IsRetail = true
    end
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

-- Export
ns.Utility = Utility
