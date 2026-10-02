--[[
$Id: Core.lua 262 2026-09-29 06:56:13Z arithmandar $
Name: LibBabble-SubZone-3.0
Revision: $Rev: 262 $
Maintainers: arith
Last updated by: $Author: arithmandar $
Website: http://www.wowace.com/addons/libbabble-subzone-3-0/
Dependencies: None
License: MIT
]]
-- ----------------------------------------------------------------------------
-- Localized Lua globals.
-- ----------------------------------------------------------------------------
-- Functions
local _G = getfenv(0)

-- Libraries

-- ----------------------------------------------------------------------------
-- AddOn namespace.
-- ----------------------------------------------------------------------------
local _, private = ...

-- ----------------------------------------------------------------------------
-- Localized Lua globals.
-- ----------------------------------------------------------------------------
-- Functions
local _G = getfenv(0)

-- Libraries
local tonumber = tonumber
local LibStub, C_Map = _G.LibStub, _G.C_Map
local GetAreaInfo = C_Map and C_Map.GetAreaInfo
local GetMapInfo = C_Map and C_Map.GetMapInfo

local MAJOR_VERSION = "LibBabble-SubZone-3.0"
local MINOR_VERSION = 100000 + tonumber(("$Rev: 262 $"):match("%d+"))

if not LibStub then error(MAJOR_VERSION .. " requires LibStub.") end
local lib = LibStub("LibBabble-3.0"):New(MAJOR_VERSION, MINOR_VERSION)
if not lib then return end

lib.MapData = private.MapData

local function resolveCandidates(candidateIDs, getLocalizedName)
	if not candidateIDs or not getLocalizedName then return end

	local resolvedName
	for candidateIndex = 1, #candidateIDs do
		local candidateID = candidateIDs[candidateIndex]
		local ok, result = pcall(getLocalizedName, candidateID)
		if ok then
			if type(result) == "table" then
				result = result.name
			end
			if type(result) == "string" and result ~= "" then
				if resolvedName and resolvedName ~= result then
					return
				end
				resolvedName = result
			end
		end
	end
	return resolvedName
end

local function resolveLocalizedName(englishName)
	if not englishName then return end
	local data = lib.MapData
	if not data then return end

	local localizedName = resolveCandidates(
		data.AreaNameToIDs and data.AreaNameToIDs[englishName],
		GetAreaInfo
	)
	if localizedName then
		return localizedName
	end

	localizedName = resolveCandidates(
		data.UiMapNameToIDs and data.UiMapNameToIDs[englishName],
		GetMapInfo
	)
	if localizedName then
		return localizedName
	end

	local areaID = data.AreaToID and data.AreaToID[englishName]
	if areaID and GetAreaInfo then
		local ok, localizedName = pcall(GetAreaInfo, areaID)
		if ok and type(localizedName) == "string" and localizedName ~= "" then
			return localizedName
		end
	end
end

if lib.SetLookupResolver then
	lib:SetLookupResolver(resolveLocalizedName)
end

-- Returns the client's localized area name when usable candidate IDs agree, or nil if unavailable or ambiguous.
function lib:GetAreaInfo(zoneName)
	if not zoneName then return end
	local data = lib.MapData
	if not data then return end

	local candidateIDs = data.AreaNameToIDs and data.AreaNameToIDs[zoneName]
	if candidateIDs then
		return resolveCandidates(candidateIDs, GetAreaInfo)
	end

	candidateIDs = data.UiMapNameToIDs and data.UiMapNameToIDs[zoneName]
	if candidateIDs then
		return resolveCandidates(candidateIDs, GetMapInfo)
	end

	local areaID = data.AreaToID and data.AreaToID[zoneName]
	if areaID and GetAreaInfo then
		local ok, localizedName = pcall(GetAreaInfo, areaID)
		if ok then return localizedName end
	end
end

private["LibBabble-SubZone-3.0-LoadingLib"] = lib
