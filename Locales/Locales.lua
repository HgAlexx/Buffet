local _, ns = ...

local locale = GetLocale()


if locale == "esMX" then locale = "esES" end

-- Missing translations fall back to the English key.
local function Fallback(_, key) return key end

--@debug@
if locale ~= "enUS" then
    local reported = {}
    Fallback = function(_, key)
        if key ~= nil and not reported[key] then
            reported[key] = true
            ns.Print(("Missing %s translation: %s"):format(locale, tostring(key)))
        end
        return key
    end
end
--@end-debug@

ns.L = setmetatable({}, { __index = Fallback })

-- Locale files call this first; only the active client locale receives the table.
function ns.NewLocale(id)
    if id == locale then return ns.L end
end
