
local lib, oldminor = LibStub:NewLibrary("tekKonfig-Heading", 1)
if not lib then return end

local stringSplit = function(str, pattern)
	local result = {}
	for each in str:gmatch(pattern) do
		table.insert(result, each)
	end
	return result
end

local tableCount = function(table)
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

-- Creates a heading and subheading
-- parent is required, texts are optional
function lib.new(parent, text, subtext)
	local title = parent:CreateFontString(nil, "ARTWORK", "GameFontNormalLarge")
	title:SetPoint("TOPLEFT", 16, -16)
	title:SetPoint("RIGHT", -16, 0)
	title:SetText(text)
	title:SetJustifyH("LEFT")

	local lines = stringSplit(subtext, "[^\r\n]+")
	local count = tableCount(lines)

	if count <= 0 then
		count = 1
	end

	local subtitle = parent:CreateFontString(nil, "ARTWORK", "GameFontHighlight")
	subtitle:SetHeight(count * 16)
	subtitle:SetPoint("TOPLEFT", title, "BOTTOMLEFT", 0, -8)
	subtitle:SetPoint("RIGHT", parent, -16, 0)
--~ 	nonSpaceWrap="true" maxLines="3"
	subtitle:SetNonSpaceWrap(true)
	subtitle:SetJustifyH("LEFT")
	subtitle:SetJustifyV("TOP")
	subtitle:SetText(subtext)

	return title, subtitle
end
