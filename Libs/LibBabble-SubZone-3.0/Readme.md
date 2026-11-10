## Overview

**LibBabble-SubZone-3.0** is a localization library for World of Warcraft zone, subzone, and location names.

It complements the names available through the WoW client APIs and [LibBabble-Zone-3.0](https://www.curseforge.com/wow/addons/libbabble-zone-3-0). Its purpose is to provide localized names for additional subzones and locations that may not be available, complete, or consistent through those sources alone.

This is a library for addon authors. It does not provide a user interface or gameplay features by itself.

## Source Code and Issues

- Source code: [GitHub](https://github.com/arithmandar/LibBabble-SubZone-3.0)
- Bug reports and missing names: [GitHub Issues](https://github.com/arithmandar/LibBabble-SubZone-3.0/issues)
- Pull requests are welcome.

## What It Provides

The library contains localized names for a wide range of World of Warcraft locations, including:

- Zones and subzones
- Instance and scenario locations
- Points of interest and notable map locations
- Taxi-node-related locations
- World Model Object (WMO) areas
- Other location names found in supported game-data tables

The database is generated from WoW client data and filtered to exclude clearly invalid or unused entries, such as names containing `NOTUSED`.

### Supported Clients

| Client | Data build |
|---|---|
| Retail (Mainline) | 12.1.5 |
| Classic Era | 1.15.9 |
| Classic Forever | 1.60.1 |
| Classic Progression | 5.5.4 |
| Classic TBC | 2.5.6 |

## For Addon Authors

Use this library when your addon needs to display a localized zone, subzone, or location name and the name is not reliably available from the WoW APIs or LibBabble-Zone-3.0.

Because this is an embedded library, end users usually do not need to install it separately. Embed it in your addon, or list it as an optional dependency if you also support a standalone installation.

### Embedding

Add it as an external in your `.pkgmeta`:

```yaml
externals:
  Libs/LibBabble-SubZone-3.0:
    url: https://github.com/arithmandar/LibBabble-SubZone-3.0
```

Then load it after LibStub in your TOC or XML:

```xml
<Include file="Libs\LibBabble-SubZone-3.0\lib.xml"/>
```

For a standalone installation, add `## OptionalDeps: LibBabble-SubZone-3.0` to your TOC.

### Usage

Retrieve the library through LibStub and use an English location name as the lookup key:

```lua
local SubZone = LibStub("LibBabble-SubZone-3.0")
local localizedName = SubZone:GetLookupTable()["Dun Morogh"]
```

`GetLookupTable()` first asks the client APIs for a localized name using generated AreaTable and UiMap ID indexes, then falls back to the current-locale table. Use this table when you want the runtime resolver.

Accessing a key that is not in the library reports a warning through the error handler and returns the key itself. To test whether an English key exists without a warning, check `GetBaseLookupTable()[name]` first.

`GetUnstrictLookupTable()`, the reverse lookup methods, and `Iterate()` expose the raw static locale data and do not invoke the resolver.

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

It also checks generated UiMap candidates. It returns nil when the input is missing, is not in the map for the current game version, the client has no name for its ID, or the matching IDs return different names.

### Building A Combined Lookup Table

Some addons, including Atlas, copy LibBabble data into their own table instead of keeping the LibBabble lookup table. In that case, iterate the base table and read each name through `GetLookupTable()`, so API-backed names are resolved:

```lua
local function GetSubZoneNames()
	local library = LibStub("LibBabble-SubZone-3.0")
	local lookup = library:GetLookupTable()
	local names = {}

	for englishName in pairs(library:GetBaseLookupTable()) do
		names[englishName] = lookup[englishName]
	end

	return names
end
```

## Documentation

- [API Reference](Docs/API.md): every public method, the lookup order, and the map data tables.
- [Integration Guide](Docs/Integration.md): embedding, load order, standalone installs, several embedded copies, and usage patterns.
- [Changelog](Docs/Changelog.md): changes in every release since 2010.
- [Maintainer Guide](Docs/Maintaining.md): data updates, `MINOR_VERSION` rules, releases, and the SVN mirror.

## Localization

Most localized names are extracted from the World of Warcraft game client, so translations do not normally need to be provided manually.

Some entries may appear untranslated because the localized name is identical to the English name.

## Known Limitations

Location names in World of Warcraft game data are not always unique. The same English name can occur in multiple records and may legitimately have different translations depending on context. LibBabble-SubZone-3.0 stores one translation for each English lookup key, so it cannot represent every context-specific variation.

Regenerated game-data exports can overwrite manual corrections. Explaining the reason for a correction in your report helps preserve it during future updates.

## Reporting Issues

If a name is missing, incorrect, or inconsistent, please open an issue on [GitHub Issues](https://github.com/arithmandar/LibBabble-SubZone-3.0/issues). Include as much of the following as possible:

- The English location name
- The affected game locale and game version
- The name shown in the game client, or the correct localized name
- The map, zone, subzone, or instance where it appears
- A screenshot, coordinates, area ID, or other reference

## Projects Using This Library

LibBabble-SubZone-3.0 is used by addons that need localized location-name lookups, including Atlas and FishingBuddy.

For the current list of known dependents, see the project's [Relations page](https://www.wowace.com/projects/libbabble-subzone-3-0/relations/dependents).

## License

LibBabble-SubZone-3.0 is released under the MIT License. The bundled LibBabble-3.0 core is in the public domain.
