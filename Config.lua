local addonName, ns = ...
local Core = ns.Core
local Utility = ns.Utility
local Const = ns.Const

local MAX_ACCOUNT_MACROS, MAX_CHARACTER_MACROS = 120, 18

local EDGEGAP, GAP = 16, 8
local tekbutt = LibStub("tekKonfig-Button")

local BACKDROP_TOOLTIP_12_12_4444 = BACKDROP_TOOLTIP_12_12_4444 or {
    bgFile = "Interface\\ChatFrame\\UI-Tooltip-Background",
    edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
    tile = true,
    tileEdge = true,
    tileSize = 12,
    edgeSize = 12,
    insets = { left = 4, right = 4, top = 4, bottom = 4 },
}

if AddonLoader and AddonLoader.RemoveInterfaceOptions then AddonLoader:RemoveInterfaceOptions("Buffet") end

local modEdit = function(parent, anchor, label, text, tips, onAction)
    local modlabel = parent:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
    modlabel:SetText(label)
    modlabel:SetPoint("TOPLEFT", anchor, "BOTTOMLEFT", 0, -5)

    local modeditbox = CreateFrame("EditBox", nil, parent, BackdropTemplateMixin and "BackdropTemplate")
    modeditbox:SetPoint("TOPLEFT", modlabel, "BOTTOMLEFT", 0, -5)
    modeditbox:SetFontObject(GameFontHighlight)
    modeditbox:SetTextInsets(8,8,8,8)
    modeditbox:SetBackdrop(BACKDROP_TOOLTIP_12_12_4444)
    modeditbox:SetBackdropColor(.1,.1,.1,.3)
    modeditbox:SetMultiLine(false)
    modeditbox:SetAutoFocus(false)
    modeditbox:SetText(text)
    modeditbox:SetScript("OnEditFocusLost", onAction)
    modeditbox:SetScript("OnEscapePressed", modeditbox.ClearFocus)
    modeditbox.tiptext = tips
    modeditbox:SetSize(200,30)

    return modeditbox
end


local frame = CreateFrame("Frame", nil, InterfaceOptionsFramePanelContainer)
frame.name = "Buffet"
frame:Hide()
frame:SetScript("OnShow", function()
    local title, subtitle = LibStub("tekKonfig-Heading").new(frame, "Buffet", "This panel allows you to quickly create the base macros for Buffet to edit.\nYou can also set the macro text to be used.")

    local function OnClick(self)
        local id = GetMacroIndexByName(self.name)
        local acc, cha = GetNumMacros()
        if id and id ~= 0 then
            PickupMacro(id)
        elseif acc >= MAX_ACCOUNT_MACROS then
            Utility.Print("Unable to create the macro, you seam to have reach the maximum number of allowed macro per account.")
        else
            local id = CreateMacro(self.name, "INV_Misc_QuestionMark", "")
            Core:Scan()
            PickupMacro(id)
        end
    end

    local hpbutt = tekbutt.new(frame, "TOPLEFT", subtitle, "BOTTOMLEFT", -2, -GAP)
    hpbutt:SetText("HP Macro")
    hpbutt.tiptext = "Generate a global macro for food, bandages, health potions and health stones."
    hpbutt.name = Const.MacroNames.defaultHP
    hpbutt:SetScript("OnClick", OnClick)
    if InCombatLockdown() then hpbutt:Disable() end

    local mpbutt = tekbutt.new(frame, "TOPLEFT", hpbutt, "TOPRIGHT", 5, 0)
    mpbutt:SetText("MP Macro")
    mpbutt.tiptext = "Generate a global macro for water, runes, mana potions and mana stones."
    mpbutt.name = Const.MacroNames.defaultMP
    mpbutt:SetScript("OnClick", OnClick)
    if InCombatLockdown() then mpbutt:Disable() end



    local hpfoodbutt = tekbutt.new(frame, "TOPLEFT", mpbutt, "TOPRIGHT", 5, 0)
    hpfoodbutt:SetText("Food Only")
    hpfoodbutt.tiptext = "Generate a global macro for food only."
    hpfoodbutt.name = Const.MacroNames.foodOnlyHP
    hpfoodbutt:SetScript("OnClick", OnClick)
    if InCombatLockdown() then hpfoodbutt:Disable() end

    local mpfoodbutt = tekbutt.new(frame, "TOPLEFT", hpfoodbutt, "TOPRIGHT", 5, 0)
    mpfoodbutt:SetText("Drink Only")
    mpfoodbutt.tiptext = "Generate a global macro for water only."
    mpfoodbutt.name = Const.MacroNames.drinkOnlyMP
    mpfoodbutt:SetScript("OnClick", OnClick)
    if InCombatLockdown() then mpfoodbutt:Disable() end



    local hppotbutt = tekbutt.new(frame, "TOPLEFT", mpfoodbutt, "TOPRIGHT", 5, 0)
    hppotbutt:SetText("Consumables")
    hppotbutt.tiptext = "Generate a global macro for health consumable only, bandages, health potions and health stones."
    hppotbutt.name = Const.MacroNames.consumableHP
    hppotbutt:SetScript("OnClick", OnClick)
    if InCombatLockdown() then hppotbutt:Disable() end

    local mppotbutt = tekbutt.new(frame, "TOPLEFT", hppotbutt, "TOPRIGHT", 5, 0)
    mppotbutt:SetText("Consumables")
    mppotbutt.tiptext = "Generate a global macro for mana consumable only, runes, mana potions and mana stones."
    mppotbutt.name = Const.MacroNames.consumableMP
    mppotbutt:SetScript("OnClick", OnClick)
    if InCombatLockdown() then mppotbutt:Disable() end



    local hpmacrolabel = frame:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
    hpmacrolabel:SetText("HP Macro")
    hpmacrolabel:SetPoint("TOPLEFT", hpbutt, "BOTTOMLEFT", 5, -GAP)

    local YOFFSET = (hpmacrolabel:GetTop() - frame:GetBottom() - EDGEGAP/3)/2

    local hpeditbox = CreateFrame("EditBox", nil, frame, BackdropTemplateMixin and "BackdropTemplate")
    hpeditbox:SetPoint("TOP", hpmacrolabel, "BOTTOM", 0, -5)
    hpeditbox:SetPoint("LEFT", EDGEGAP/3, 0)
    hpeditbox:SetPoint("BOTTOMRIGHT", -EDGEGAP/3, YOFFSET + EDGEGAP/3)
    hpeditbox:SetFontObject(GameFontHighlight)
    hpeditbox:SetTextInsets(8,8,8,8)
    hpeditbox:SetBackdrop(BACKDROP_TOOLTIP_12_12_4444)
    hpeditbox:SetBackdropColor(.1,.1,.1,.3)
    hpeditbox:SetMultiLine(true)
    hpeditbox:SetAutoFocus(false)
    hpeditbox:SetText(Core.db.macroHP)
    hpeditbox:SetScript("OnEditFocusLost", function()
        local newmacro = hpeditbox:GetText()
        if not newmacro:find("%%MACRO%%") then
            Utility.Print('Macro text must contain the string "%MACRO%".')
        else
            Core.db.macroHP = newmacro
            Core:QueueScan()
        end
    end)
    hpeditbox:SetScript("OnEscapePressed", hpeditbox.ClearFocus)
    hpeditbox.tiptext = 'Customize the macro text.  Must include the string "%MACRO%", which is replaced with the items to be used.  This setting is saved on a per-char basis.'
    hpeditbox:SetScript("OnEnter", mpbutt:GetScript("OnEnter"))
    hpeditbox:SetScript("OnLeave", mpbutt:GetScript("OnLeave"))

    local mpmacrolabel = frame:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
    mpmacrolabel:SetText("MP Macro")
    mpmacrolabel:SetPoint("TOP", hpeditbox, "BOTTOM", 0, -GAP)
    mpmacrolabel:SetPoint("LEFT", hpmacrolabel, "LEFT")

    local mpeditbox = CreateFrame("EditBox", nil, frame, BackdropTemplateMixin and "BackdropTemplate")
    mpeditbox:SetPoint("TOP", mpmacrolabel, "BOTTOM", 0, -5)
    mpeditbox:SetPoint("LEFT", EDGEGAP/3, 0)
    mpeditbox:SetPoint("BOTTOMRIGHT", -EDGEGAP/3, EDGEGAP/3)
    mpeditbox:SetFontObject(GameFontHighlight)
    mpeditbox:SetTextInsets(8,8,8,8)
    mpeditbox:SetBackdrop(BACKDROP_TOOLTIP_12_12_4444)
    mpeditbox:SetBackdropColor(.1,.1,.1,.3)
    mpeditbox:SetMultiLine(true)
    mpeditbox:SetAutoFocus(false)
    mpeditbox:SetText(Core.db.macroMP)
    mpeditbox:SetScript("OnEditFocusLost", function()
        local newmacro = mpeditbox:GetText()
        if not newmacro:find("%%MACRO%%") then
            Utility.Print('Macro text must contain the string "%MACRO%".')
        else
            Core.db.macroMP = newmacro
            Core:QueueScan()
        end
    end)
    mpeditbox:SetScript("OnEscapePressed", mpeditbox.ClearFocus)
    mpeditbox.tiptext = hpeditbox.tiptext
    mpeditbox:SetScript("OnEnter", mpbutt:GetScript("OnEnter"))
    mpeditbox:SetScript("OnLeave", mpbutt:GetScript("OnLeave"))

    frame:SetScript("OnEvent", function(self, event)
        if event == "PLAYER_REGEN_DISABLED" then
            hpbutt:Disable()
            mpbutt:Disable()
            hpfoodbutt:Disable()
            mpfoodbutt:Disable()
            hppotbutt:Disable()
            mppotbutt:Disable()
        else
            hpbutt:Enable()
            mpbutt:Enable()
            hpfoodbutt:Enable()
            mpfoodbutt:Enable()
            hppotbutt:Enable()
            mppotbutt:Enable()
        end
    end)
    frame:RegisterEvent("PLAYER_REGEN_ENABLED")
    frame:RegisterEvent("PLAYER_REGEN_DISABLED")

    frame:SetScript("OnShow", nil)
end)

InterfaceOptions_AddCategory(frame)

local frame_config = CreateFrame("Frame", nil, InterfaceOptionsFramePanelContainer)
frame_config.name = "Configuration"
frame_config.parent = "Buffet"
frame_config:Hide()
frame_config:SetScript("OnShow", function()
    local title, subtitle = LibStub("tekKonfig-Heading").new(
        frame_config,
        "Configuration",
        "This panel allows you to configure all the macros.\nModifiers use macro syntax: nomod | mod:key | mod:key1/key2 | mod:key1,mod:key2\nEmpty modifiers to disable them."
    )

    local header = frame_config:CreateFontString(nil, "ARTWORK", "GameFontNormalLarge")
    header:SetPoint("TOPLEFT", subtitle, "BOTTOMLEFT", 0, -16)
    header:SetText("Main Macros: AutoHP & AutoMP")

    local combatCheckButton = CreateFrame("CheckButton", "CombatCheckButton", frame_config, "ChatConfigCheckButtonTemplate")
    CombatCheckButtonText:SetText("Enable combat mode")
    combatCheckButton.tooltip = "Check this to enable in-combat items in macro"
    combatCheckButton:SetPoint("TOPLEFT", header, "BOTTOMLEFT", 0, -5)
    combatCheckButton:SetChecked(Core.db.combat)
    combatCheckButton:SetScript("OnClick",
        function()
            if combatCheckButton:GetChecked() then
                Core.db.combat = true
            else
                Core.db.combat = false
            end
            Core:QueueScan()
        end
    )

    local hearthstoneCheckButton = CreateFrame("CheckButton", "HearthstoneCheckButton", frame_config, "ChatConfigCheckButtonTemplate")
    HearthstoneCheckButtonText:SetText("Default to hearthstone")
    hearthstoneCheckButton.tooltip = "Check this to default to hearthstone"
    hearthstoneCheckButton:SetPoint("TOPLEFT", combatCheckButton, "BOTTOMLEFT", 0, -5)
    hearthstoneCheckButton:SetChecked(Core.db.hearthstone)
    hearthstoneCheckButton:SetScript("OnClick",
        function()
            if hearthstoneCheckButton:GetChecked() then
                Core.db.hearthstone = true
            else
                Core.db.hearthstone = false
            end
            Core:QueueScan()
        end
    )

    local modConjured = modEdit(
        frame_config,
        hearthstoneCheckButton,
        "In-Combat: conjured items modifier (mana gems, healthstone)",
        Core.db.modConjured,
        "Modifier for in-combat conjured items",
        function(self)
            local mod = self:GetText() or ""
            if Core.db.modConjured ~= mod then
                Core.db.modConjured = mod
                Core:QueueScan()
            end
        end
    )

    local modPotion = modEdit(
        frame_config,
        modConjured,
        "In-Combat: potion items modifier",
        Core.db.modPotion,
        "Modifier for in-combat potion items",
        function(self)
            local mod = self:GetText() or ""
            if Core.db.modPotion ~= mod then
                Core.db.modPotion = mod
                Core:QueueScan()
            end
        end
    )

    local modSpecial = modEdit(
        frame_config,
        modPotion,
        "Special items modifier (bandage, runes)",
        Core.db.modSpecial,
        "Modifier for special items",
        function(self)
            local mod = self:GetText() or ""
            if Core.db.modSpecial ~= mod then
                Core.db.modSpecial = mod
                Core:QueueScan()
            end
        end
    )

    local header = frame_config:CreateFontString(nil, "ARTWORK", "GameFontNormalLarge")
    header:SetPoint("TOPLEFT", modSpecial, "BOTTOMLEFT", 0, -16)
    header:SetText("Consumables Macros: ConsumableHP & ConsumableMP")

    local consModConjured = modEdit(
        frame_config,
        header,
        "Conjured items modifier (mana gems, healthstone)",
        Core.db.consModConjured,
        "Modifier for in-combat conjured items",
        function(self)
            local mod = self:GetText() or ""
            if Core.db.consModConjured ~= mod then
                Core.db.consModConjured = mod
                Core:QueueScan()
            end
        end
    )

    local consModPotion = modEdit(
        frame_config,
        consModConjured,
        "Potion items modifier",
        Core.db.consModPotion,
        "Modifier for in-combat potion items",
        function(self)
            local mod = self:GetText() or ""
            if Core.db.consModPotion ~= mod then
                Core.db.consModPotion = mod
                Core:QueueScan()
            end
        end
    )

    local consModSpecial = modEdit(
        frame_config,
        consModPotion,
        "Special items modifier (bandage, runes)",
        Core.db.modSpecial,
        "Modifier for special items",
        function(self)
            local mod = self:GetText() or ""
            if Core.db.consModSpecial ~= mod then
                Core.db.consModSpecial = mod
                Core:QueueScan()
            end
        end
    )

    frame_config:SetScript("OnShow", nil)
end)

InterfaceOptions_AddCategory(frame_config)



LibStub("tekKonfig-AboutPanel").new("Buffet", "Buffet")


----------------------------------------
--      Quicklaunch registration      --
----------------------------------------

LibStub:GetLibrary("LibDataBroker-1.1"):NewDataObject("Buffet", {
    type = "launcher",
    icon = "Interface\\Icons\\INV_Misc_Food_DimSum",
    OnClick = function()
        InterfaceOptionsFrame_OpenToCategory(frame)
        InterfaceOptionsFrame_OpenToCategory(frame_config)
        InterfaceOptionsFrame_OpenToCategory(frame)
    end,
})
