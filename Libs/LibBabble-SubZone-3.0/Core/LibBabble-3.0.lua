-- LibBabble-3.0 is hereby placed in the Public Domain
-- Credits: ckknight
local LIBBABBLE_MAJOR, LIBBABBLE_MINOR = "LibBabble-3.0", 3

local LibBabble = LibStub:NewLibrary(LIBBABBLE_MAJOR, LIBBABBLE_MINOR)
if not LibBabble then
	return
end

local data = LibBabble.data or {}
for k,v in pairs(LibBabble) do
	LibBabble[k] = nil
end
LibBabble.data = data

local tablesToDB = {}
for namespace, db in pairs(data) do
	for k,v in pairs(db) do
		tablesToDB[v] = db
	end
end

local function warn(message)
	local _, ret = pcall(error, message, 3)
	geterrorhandler()(ret)
end

local lookup_mt = { __index = function(self, key)
	local db = tablesToDB[self]
	local resolved_key = db.lookupResolver and db.lookupResolver(key)
	if resolved_key then
		rawset(self, key, resolved_key)
		return resolved_key
	end
	local current_key = db.current[key]
	if current_key then
		self[key] = current_key
		return current_key
	end
	local base_key = db.base[key]
	local real_MAJOR_VERSION
	for k,v in pairs(data) do
		if v == db then
			real_MAJOR_VERSION = k
			break
		end
	end
	if not real_MAJOR_VERSION then
		real_MAJOR_VERSION = LIBBABBLE_MAJOR
	end
	if base_key then
		warn(("%s: Translation %q not found for locale %q"):format(real_MAJOR_VERSION, key, GetLocale()))
		rawset(self, key, base_key)
		return base_key
	end
	warn(("%s: Translation %q not found."):format(real_MAJOR_VERSION, key))
	rawset(self, key, key)
	return key
end }

local function initLookup(module, lookup)
	local db = tablesToDB[module]
	for k in pairs(lookup) do
		lookup[k] = nil
	end
	setmetatable(lookup, lookup_mt)
	tablesToDB[lookup] = db
	db.lookup = lookup
	return lookup
end

local function initReverse(module, reverse)
	local db = tablesToDB[module]
	for k in pairs(reverse) do
		reverse[k] = nil
	end
	for k,v in pairs(db.current) do
		reverse[v] = k
	end
	tablesToDB[reverse] = db
	db.reverse = reverse
	db.reverseIterators = nil
	return reverse
end

local prototype = {}
local prototype_mt = {__index = prototype}

-- #NODOC
-- Modules may register a resolver that takes precedence over locale translations.
function prototype:SetLookupResolver(resolver)
	local db = tablesToDB[self]
	db.lookupResolver = resolver
	if db.lookup then
		initLookup(self, db.lookup)
	end
end

--[[---------------------------------------------------------------------------
Notes:
	* A registered resolver is checked before the current-locale table.
	* If no resolver result or current-locale translation is available, accessing a known key warns and returns its base (English) value; an unknown key warns and returns itself.
Returns:
	A lookup table from English keys to current-locale values, with warning and fallback behavior for missing translations.
Example:
	local B = LibStub("LibBabble-Module-3.0") -- where Module is what you want.
	local BL = B:GetLookupTable()
	assert(BL["Some english word"] == "Some localized word")
	DoSomething(BL["Some english word that doesn't exist"]) -- warning!
-----------------------------------------------------------------------------]]
function prototype:GetLookupTable()
	local db = tablesToDB[self]

	local lookup = db.lookup
	if lookup then
		return lookup
	end
	return initLookup(self, {})
end
--[[---------------------------------------------------------------------------
Notes:
	* Returns the raw current translation table directly; the module's lookup resolver is not applied.
	* Keys without a current translation return nil and do not trigger warnings.
Returns:
	The current translation table, mapping English keys to current-locale values.
Example:
	local B = LibStub("LibBabble-Module-3.0") -- where Module is what you want.
	local B_has = B:GetUnstrictLookupTable()
	assert(B_has["Some english word"] == "Some localized word")
	assert(B_has["Some english word that doesn't exist"] == nil)
-----------------------------------------------------------------------------]]
function prototype:GetUnstrictLookupTable()
	local db = tablesToDB[self]

	return db.current
end
--[[---------------------------------------------------------------------------
Notes:
	* Returns the base (English) table directly; keys not present in that table return nil.
	* Use this to check whether an English key exists, regardless of whether it has a current-locale translation.
Returns:
	The base table, mapping each English key to its English value.
Example:
	local B = LibStub("LibBabble-Module-3.0") -- where Module is what you want.
	local B_hasBase = B:GetBaseLookupTable()
	assert(B_hasBase["Some english word"] == "Some english word")
	assert(B_hasBase["Some english word that doesn't exist"] == nil)
-----------------------------------------------------------------------------]]
function prototype:GetBaseLookupTable()
	local db = tablesToDB[self]

	return db.base
end
--[[---------------------------------------------------------------------------
Notes:
	* Keys without a current-locale translation return nil.
	* If multiple English keys share a localized value, this table returns only one of them; use :GetReverseIterator("word") to retrieve all matches.
	* Reverse lookup tables are built from the raw current translation table, not dynamic lookup-resolver results.
Returns:
	A lookup table from current-locale values to English keys.
Example:
	local B = LibStub("LibBabble-Module-3.0") -- where Module is what you want.
	local BR = B:GetReverseLookupTable()
	assert(BR["Some localized word"] == "Some english word")
	assert(BR["Some localized word that doesn't exist"] == nil)
-----------------------------------------------------------------------------]]
function prototype:GetReverseLookupTable()
	local db = tablesToDB[self]

	local reverse = db.reverse
	if reverse then
		return reverse
	end
	return initReverse(self, {})
end
local blank = {}
local weakVal = {__mode='v'}
--[[---------------------------------------------------------------------------
Arguments:
	key - the localized value whose matching English keys should be traversed.
Returns:
	An iterator over all English keys that map to the given current-locale value.
Example:
	local B = LibStub("LibBabble-Module-3.0") -- where Module is what you want.
	for word in B:GetReverseIterator("Some localized word") do
		DoSomething(word)
	end
-----------------------------------------------------------------------------]]
function prototype:GetReverseIterator(key)
	local db = tablesToDB[self]
	local reverseIterators = db.reverseIterators
	if not reverseIterators then
		reverseIterators = setmetatable({}, weakVal)
		db.reverseIterators = reverseIterators
	elseif reverseIterators[key] then
		return pairs(reverseIterators[key])
	end
	local t
	for k,v in pairs(db.current) do
		if v == key then
			if not t then
				t = {}
			end
			t[k] = true
		end
	end
	reverseIterators[key] = t or blank
	return pairs(reverseIterators[key])
end
--[[---------------------------------------------------------------------------
Returns:
	An iterator over the current translation table's English-key/current-locale-value pairs.
Example:
	local B = LibStub("LibBabble-Module-3.0") -- where Module is what you want.
	for english, localized in B:Iterate() do
		DoSomething(english, localized)
	end
-----------------------------------------------------------------------------]]
function prototype:Iterate()
	local db = tablesToDB[self]

	return pairs(db.current)
end

-- #NODOC
-- modules need to call this to set the base table
function prototype:SetBaseTranslations(base)
	local db = tablesToDB[self]
	local oldBase = db.base
	if oldBase then
		for k in pairs(oldBase) do
			oldBase[k] = nil
		end
		for k, v in pairs(base) do
			oldBase[k] = v
		end
		base = oldBase
	else
		db.base = base
	end
	for k,v in pairs(base) do
		if v == true then
			base[k] = k
		end
	end
end

local function init(module)
	local db = tablesToDB[module]
	if db.lookup then
		initLookup(module, db.lookup)
	end
	if db.reverse then
		initReverse(module, db.reverse)
	end
	db.reverseIterators = nil
end

-- #NODOC
-- modules need to call this to set the current table. if current is true, use the base table.
function prototype:SetCurrentTranslations(current)
	local db = tablesToDB[self]
	if current == true then
		db.current = db.base
	else
		local oldCurrent = db.current
		if oldCurrent then
			for k in pairs(oldCurrent) do
				oldCurrent[k] = nil
			end
			for k, v in pairs(current) do
				oldCurrent[k] = v
			end
			current = oldCurrent
		else
			db.current = current
		end
	end
	init(self)
end

for namespace, db in pairs(data) do
	setmetatable(db.module, prototype_mt)
	init(db.module)
end

-- #NODOC
-- modules need to call this to create a new namespace.
function LibBabble:New(namespace, minor)
	local module, oldminor = LibStub:NewLibrary(namespace, minor)
	if not module then
		return
	end

	if not oldminor then
		local db = {
			module = module,
		}
		data[namespace] = db
		tablesToDB[module] = db
	else
		for k,v in pairs(module) do
			module[k] = nil
		end
	end

	setmetatable(module, prototype_mt)

	return module
end
