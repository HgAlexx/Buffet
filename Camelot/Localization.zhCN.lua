local _, ns = ...

-- Item-tooltip vocabulary and patterns are shared across zhCN clients.
if ns.Utility.IsCamelot and GetLocale() == "zhCN" then
    ns.Locales = ns.ZhCNItemLocales
end
