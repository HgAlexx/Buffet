## Overview

**LibBabble-SubZone-3.0** is a localization library for World of Warcraft zone, subzone, and location names.

It complements the names available through the WoW client APIs and [LibBabble-Zone-3.0](https://www.curseforge.com/wow/addons/libbabble-zone-3-0). Its purpose is to provide localized names for additional subzones and locations that may not be available, complete, or consistent through those sources alone.

This is a library for addon authors. It does not provide a user interface or gameplay features by itself.

## What It Provides

The library contains localized names for a wide range of World of Warcraft locations, including:

- Zones and subzones
- Instance and scenario locations
- Points of interest and notable map locations
- Taxi-node-related locations
- World Model Object (WMO) areas
- Other location names found in supported game-data tables

The database is generated from WoW client data and filtered to exclude clearly invalid or unused entries, such as names containing `NOTUSED`.

## For Addon Authors

Use this library when your addon needs to display a localized zone, subzone, or location name and the name is not reliably available from the WoW APIs or LibBabble-Zone-3.0.

Because this is an embedded library, end users usually do not need to install or update it separately. Addons that depend on it should include a compatible release or declare it as an optional dependency, according to their packaging requirements.

### Usage

Retrieve the library through LibStub and use an English location name as the lookup key:

```lua
local SubZone = LibStub("LibBabble-SubZone-3.0")
local localizedName = SubZone:GetLookupTable()["Dun Morogh"]
```

`GetLookupTable()` first asks the client APIs for a localized name using generated AreaTable and UiMap ID indexes, then falls back to the current-locale table. If no translation or API result exists for a known key, it returns the English key. Addons should use this lookup table when they want the runtime resolver. `GetUnstrictLookupTable()`, reverse lookup methods, and `Iterate()` expose raw static locale data and do not invoke the resolver.

To find English keys for a localized value, use `GetReverseLookupTable()` for one match or `GetReverseIterator()` for every match. `Iterate()` traverses the current English-to-localized translation pairs:

```lua
for englishName, localizedName in SubZone:Iterate() do
	-- Use each translated location name.
end

for englishName in SubZone:GetReverseIterator(localizedName) do
	-- Handle every English key with this localized value.
end
```

For an area name present in the client area map, `GetAreaInfo()` returns the localized name provided by the WoW client:

```lua
local localizedName = SubZone:GetAreaInfo("Dun Morogh")
```

It returns nil when the input is missing, is not in the map for the current game version, or the client has no area name for its ID. The same method also checks generated UiMap candidates.

### Building A Combined Lookup Table

Some addons, including Atlas, copy LibBabble data into their own table instead of retaining the LibBabble lookup table. In that case, start with `GetLookupTable()` so API-backed names are resolved, and provide an English fallback for names that are unavailable in the client API:

```lua
local function GetSubZoneNames()
	local library = LibStub("LibBabble-SubZone-3.0")
	local names = {}
	local lookup = library:GetLookupTable()
	local base = library:GetBaseLookupTable()

	for englishName in pairs(base) do
		names[englishName] = lookup[englishName] or englishName
	end

	return names
end
```

## Localization

Most localized zone, subzone, and location names are extracted from the World of Warcraft game client.

Users do not normally need to provide translations manually. If you find a missing, incorrect, or inconsistent name, please report it through the project’s issue tracker or CurseForge comments.

When reporting an issue, include as much context as possible:

- The English location name
- The affected game locale
- The name shown in the game client, if available
- The zone, subzone, map, or instance where it appears
- A screenshot, area ID, or other reference when possible

Some entries may appear untranslated because the localized name is identical to the English name.

## Known Limitations

Location names in World of Warcraft game data are not always unique.

The same English name can occur in multiple records and may legitimately have different localized translations depending on context. LibBabble-SubZone-3.0 stores one translation for each English lookup key, so it cannot represent every context-specific variation.

If you find an incorrect, missing, or inconsistent translation, please report it with as much context as possible, including:

- The English location name
- The affected game locale
- The correct localized name
- The map, zone, subzone, or game-data context
- A screenshot or game reference, if available

Please note that regenerated game-data exports can overwrite manual corrections. Including an explanation in the report helps preserve the intended correction during future updates.

## Missing Locations and Issues

If a zone, subzone, or location is missing from the library, please report it through the project’s issue tracker.

Include the English name, localized name if known, game version, and any available context such as the map name, coordinates, area ID, or a screenshot.

## Projects Using This Library

LibBabble-SubZone-3.0 is used by addons that need localized location-name lookups, including projects such as Atlas and FishingBuddy.

For the current list of known dependents, see the project’s [Relations page](https://www.wowace.com/projects/libbabble-subzone-3-0/relations/dependents).