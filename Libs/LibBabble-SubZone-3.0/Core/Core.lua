--[[
Name: LibBabble-SubZone-3.0
Maintainers: arith
Last updated by: arith
Website: https://www.curseforge.com/wow/addons/libbabble-subzone-3-0
Dependencies: None
License: MIT
]]
local _, private = ...

local MAJOR_VERSION = "LibBabble-SubZone-3.0"
-- MINOR_VERSION must increase with every release. It used to be derived from the SVN
-- Rev keyword (last SVN revision: 268, i.e. 100268); it is now set manually so that
-- Git and SVN builds share the same value.
local MINOR_VERSION = 100301

local _G = getfenv(0)

local LibStub = _G.LibStub

if not LibStub then error(MAJOR_VERSION .. " requires LibStub.") end
local lib = LibStub("LibBabble-3.0"):New(MAJOR_VERSION, MINOR_VERSION)
if not lib then return end

local C_Map = _G.C_Map
local GetAreaInfo = C_Map and C_Map.GetAreaInfo
local GetMapInfo = C_Map and C_Map.GetMapInfo

-- Data files fill this table. They load after this file and skip themselves
-- when this copy did not win the LibStub version check, so only one copy builds it.
lib.MapData = {}

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
