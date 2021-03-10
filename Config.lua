local addonName, ns = ...

-- Imports
local Core = ns.Core
local Utility = ns.Utility
local Const = ns.Const
local Config = {}

local MAX_ACCOUNT_MACROS, MAX_CHARACTER_MACROS = 120, 18

local EDGEGAP, GAP = 16, 5
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

local GameTooltip = GameTooltip
local function HideTooltip()
    GameTooltip:Hide()
end
local function ShowTooltip(self)
    if self.tiptext then
        GameTooltip:SetOwner(self, "ANCHOR_TOP")
        GameTooltip:SetText(self.tiptext, nil, nil, nil, nil, true)
    end
end

local makeLabel = function(parent, label)
    local l = parent:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
    l:SetText(label)
    return l
end

local makeEditbox = function(parent, text, tips, onAction)
    local e = CreateFrame("EditBox", nil, parent, BackdropTemplateMixin and "BackdropTemplate")
    e:SetFontObject(GameFontHighlight)
    e:SetTextInsets(8,8,8,8)
    e:SetBackdrop(BACKDROP_TOOLTIP_12_12_4444)
    e:SetBackdropColor(.1,.1,.1,.3)
    e:SetMultiLine(false)
    e:SetAutoFocus(false)
    e:SetText(text)
    e.tiptext = tips
    e:SetScript("OnEditFocusLost", onAction)
    e:SetScript("OnEscapePressed", e.ClearFocus)
    e:SetScript("OnEnter", ShowTooltip)
    e:SetScript("OnLeave", HideTooltip)
    return e
end

local modEdit = function(parent, anchor, label, text, tips, onAction)
    local modlabel = makeLabel(parent, label)
    modlabel:SetPoint("TOPLEFT", anchor, "BOTTOMLEFT", 0, -5)
    local modeditbox = makeEditbox(parent, text, tips, onAction)
    modeditbox:SetSize(200, 30)
    modeditbox:SetPoint("TOPLEFT", modlabel, "BOTTOMLEFT", 0, -5)
    return modeditbox
end

local largeEdit = function(parent, anchor, label, text, tips, onAction)
    local modlabel = makeLabel(parent, label)
    modlabel:SetPoint("TOPLEFT", anchor, "BOTTOMLEFT", 0, -GAP)
    local modeditbox = makeEditbox(parent, text, tips, onAction)
    modeditbox:SetHeight(30)
    modeditbox:SetPoint("TOP", modlabel, "BOTTOM", 0, -GAP)
    modeditbox:SetPoint("LEFT", parent, "RIGHT", -EDGEGAP, 0)
    modeditbox:SetPoint("RIGHT", parent, "LEFT", EDGEGAP, 0)
    return modeditbox
end

local largeBottomEdit = function(parent, anchor, label, text, tips, onAction)
    local modeditbox = makeEditbox(parent, text, tips, onAction)
    modeditbox:SetHeight(16*3)
    modeditbox:SetPoint("BOTTOM", anchor, "TOP", 0, GAP)
    modeditbox:SetPoint("LEFT", parent, "RIGHT", -EDGEGAP, 0)
    modeditbox:SetPoint("RIGHT", parent, "LEFT", EDGEGAP, 0)
    local modlabel = makeLabel(parent, label)
    modlabel:SetPoint("BOTTOMLEFT", modeditbox, "TOPLEFT", 0, GAP)
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
            if not InCombatLockdown() then
                Core:Scan()
            end
            PickupMacro(id)
        end
    end

    local hpbutt = tekbutt.new(frame, "TOPLEFT", subtitle, "BOTTOMLEFT", -10, -GAP)
    hpbutt:SetText("HP Macro")
    hpbutt.tiptext = "Generate a global macro for food, bandages, health potions and health stones."
    hpbutt.name = Const.MacroNames.defaultHP
    hpbutt:SetScript("OnClick", OnClick)
    if InCombatLockdown() then hpbutt:Disable() end

    local mpbutt = tekbutt.new(frame, "TOPLEFT", hpbutt, "TOPRIGHT", 0, 0)
    mpbutt:SetText("MP Macro")
    mpbutt.tiptext = "Generate a global macro for water, runes, mana potions and mana stones."
    mpbutt.name = Const.MacroNames.defaultMP
    mpbutt:SetScript("OnClick", OnClick)
    if InCombatLockdown() then mpbutt:Disable() end



    local hpfoodbutt = tekbutt.new(frame, "TOPLEFT", mpbutt, "TOPRIGHT", 0, 0)
    hpfoodbutt:SetText("Food Only")
    hpfoodbutt.tiptext = "Generate a global macro for food only."
    hpfoodbutt.name = Const.MacroNames.foodOnlyHP
    hpfoodbutt:SetScript("OnClick", OnClick)
    if InCombatLockdown() then hpfoodbutt:Disable() end

    local mpfoodbutt = tekbutt.new(frame, "TOPLEFT", hpfoodbutt, "TOPRIGHT", 0, 0)
    mpfoodbutt:SetText("Drink Only")
    mpfoodbutt.tiptext = "Generate a global macro for water only."
    mpfoodbutt.name = Const.MacroNames.drinkOnlyMP
    mpfoodbutt:SetScript("OnClick", OnClick)
    if InCombatLockdown() then mpfoodbutt:Disable() end



    local hppotbutt = tekbutt.new(frame, "TOPLEFT", mpfoodbutt, "TOPRIGHT", 0, 0)
    hppotbutt:SetText("HP Cons.")
    hppotbutt.tiptext = "Generate a global macro for health consumable only, bandages, health potions and health stones."
    hppotbutt.name = Const.MacroNames.consumableHP
    hppotbutt:SetScript("OnClick", OnClick)
    if InCombatLockdown() then hppotbutt:Disable() end

    local mppotbutt = tekbutt.new(frame, "TOPLEFT", hppotbutt, "TOPRIGHT", 0, 0)
    mppotbutt:SetText("MP Cons.")
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

    local hearthstoneCheckButton = CreateFrame("CheckButton", "HearthstoneCheckButton", frame_config, "ChatConfigCheckButtonTemplate")
    HearthstoneCheckButtonText:SetText("Default to hearthstone (all macros)")
    hearthstoneCheckButton.tooltip = "Check this to default to hearthstone"
    hearthstoneCheckButton:SetPoint("TOPLEFT", subtitle, "BOTTOMLEFT", 0, -16)
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

    local wellFedCheckButton = CreateFrame("CheckButton", "wellFedCheckButton", frame_config, "ChatConfigCheckButtonTemplate")
    wellFedCheckButtonText:SetText("Also consider well fed items (all macros)")
    wellFedCheckButton.tooltip = "Check this to also consider well fed items"
    wellFedCheckButton:SetPoint("TOPLEFT", hearthstoneCheckButton, "BOTTOMLEFT", 0, -5)
    wellFedCheckButton:SetChecked(Core.db.wellFed)
    wellFedCheckButton:SetScript("OnClick",
        function()
            if wellFedCheckButton:GetChecked() then
                Core.db.wellFed = true
            else
                Core.db.wellFed = false
            end
            Core:QueueScan()
        end
    )

    local header = frame_config:CreateFontString(nil, "ARTWORK", "GameFontNormalLarge")
    header:SetPoint("TOPLEFT", wellFedCheckButton, "BOTTOMLEFT", 0, -5)
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

    local modConjured = modEdit(
        frame_config,
        combatCheckButton,
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


local customMacro = {}
customMacro.active = nil
customMacro.saved = false
customMacro.valid = false

customMacro.nameEdit = nil
customMacro.sourceEdit = nil
customMacro.outputEdit = nil

customMacro.buttonNew = nil
customMacro.buttonLoad = nil
customMacro.buttonCheck = nil
customMacro.buttonDelete = nil
customMacro.buttonPick = nil
customMacro.buttonSave = nil

StaticPopupDialogs["BUFFET_DELETE_MACRO_CONFIRM"] = {
    text = "%s",
    button1 = ACCEPT,
    button2 = CANCEL,
    OnAccept = nil,
    showAlert = 1,
    timeout = 0,
    whileDead = 1,
    hideOnEscape = 1
};

function customMacro:ui()
    if UnitAffectingCombat("player") then
        customMacro.buttonNew:Disable()
        customMacro.buttonLoad:Disable()
        customMacro.buttonCheck:Disable()
        customMacro.buttonDelete:Disable()
        customMacro.buttonSave:Disable()
        customMacro.buttonPick:Disable()

        customMacro.nameEdit:Disable()
        customMacro.sourceEdit:Disable()
    else
        customMacro.buttonNew:Enable()
        customMacro.buttonLoad:Enable()
        customMacro.nameEdit:Enable()
        customMacro.sourceEdit:Enable()

        if self.active then
            customMacro.buttonDelete:Enable()
            customMacro.buttonCheck:Enable()

            if self.active.key then
                customMacro.buttonDelete:SetText("Delete the macro")
            else
                customMacro.buttonDelete:SetText("Clear inputs")
            end

            if self.valid then
                if self.saved then
                    customMacro.buttonSave:Disable()
                    customMacro.buttonPick:Enable()
                else
                    customMacro.buttonSave:Enable()
                    customMacro.buttonPick:Disable()
                end
            else
                customMacro.buttonSave:Disable()
                customMacro.buttonPick:Disable()
            end
        else
            customMacro.buttonCheck:Disable()
            customMacro.buttonDelete:Disable()
            customMacro.buttonSave:Disable()
            customMacro.buttonPick:Disable()
        end
    end
end

function customMacro:updateStatus()
    if customMacro.active then
        if customMacro.active.key then -- from load / save
            local macro = Core.customMacros[customMacro.active.key]
            local name = macro.name
            local source = macro.source
            customMacro.saved = not (name ~= customMacro.active.name or source ~= customMacro.active.source)
            customMacro.valid = customMacro.valid or (source == customMacro.active.source)
        else -- from new
            customMacro.valid = customMacro.valid or (customMacro.active.source == Const.newMacroSource)
        end
    end
end

function customMacro:menu()
    local list = {}
    for k, v in pairs(Core.customMacros) do
        table.insert(list, k)
    end
    table.sort(list)

    local makeItem = function(text, value, isTitle)
        local info = {}
        info.text = text
        info.value = value
        info.isTitle = isTitle
        info.notCheckable = true
        info.func = function(self)
            customMacro:load(self.value)
        end
        return info
    end

    if #list > 0 then
        local item = makeItem("Macros", nil, true)
        UIDropDownMenu_AddButton(item);
        UIDropDownMenu_AddSeparator()
        for i = 1, #list do
            local name = list[i]
            item = makeItem(name, name, false)
            UIDropDownMenu_AddButton(item);
        end
    else
        local item = makeItem("Nothing yet", nil, true)
        UIDropDownMenu_AddButton(item);
    end
end

function customMacro:new()
    if customMacro.active and customMacro.active.key and not customMacro.saved then
        customMacro:confirm("Unsaved changes, are you sure?", function(self)
            customMacro.saved = false
            customMacro.valid = true
            customMacro.active = {}
            customMacro.active.key = nil
            customMacro.active.name = "MacroName"
            customMacro.active.source = Const.newMacroSource

            customMacro:loadActive()
            customMacro:ui()
        end)
    else
        customMacro.saved = false
        customMacro.valid = true
        customMacro.active = {}
        customMacro.active.key = nil
        customMacro.active.name = "MacroName"
        customMacro.active.source = Const.newMacroSource

        customMacro:loadActive()
        customMacro:ui()
    end
end

function customMacro:load(value)
    if customMacro.active and customMacro.active.key and not customMacro.saved then
        customMacro:confirm("Unsaved changes, are you sure?", function(self)
            local macro = Core.customMacros[value]

            customMacro.saved = true
            customMacro.valid = true
            customMacro.active = {}
            customMacro.active.key = macro.name
            customMacro.active.name = macro.name
            customMacro.active.source = macro.source

            customMacro:loadActive()
            customMacro:ui()
        end)
    else
        local macro = Core.customMacros[value]

        customMacro.saved = true
        customMacro.valid = true
        customMacro.active = {}
        customMacro.active.key = macro.name
        customMacro.active.name = macro.name
        customMacro.active.source = macro.source

        customMacro:loadActive()
        customMacro:ui()
    end
end

function customMacro:loadActive()
    if self.active then
        if self.active.name then
            self.nameEdit:SetText(self.active.name)
        end
        self.nameEdit:Enable()

        if self.active.source then
            self.sourceEdit:SetText(self.active.source)
        end
        self.sourceEdit:Enable()

        self.outputEdit:SetText("")

        customMacro:checkAll()
    else
        self.nameEdit:SetText("")
        self.nameEdit:Disable()
        self.sourceEdit:SetText("")
        self.sourceEdit:Disable()
        self.outputEdit:SetText("")
    end
end

function customMacro:confirm(text, onAccept)
    StaticPopupDialogs["BUFFET_DELETE_MACRO_CONFIRM"].OnAccept = onAccept
    StaticPopup_Show("BUFFET_DELETE_MACRO_CONFIRM", text);
end

function customMacro:reset()
    customMacro.saved = false
    customMacro.valid = false
    customMacro.active= nil

    customMacro:loadActive()
    customMacro:ui()
end

function customMacro:delete()
    if customMacro.active and customMacro.active.key and Core.customMacros[customMacro.active.key] then
        customMacro:confirm("Are you sure you want to delete this macro?", function(self)
            local macroId = GetMacroIndexByName(customMacro.active.key)
            if macroId > 0 then
                DeleteMacro(macroId)
            end
            Core.customMacros[customMacro.active.key] = nil
            customMacro:reset()
        end)
    else
        customMacro:reset()
    end
end

function customMacro:save()
    if self.active then
        if self.active.name == "" then
            self.outputEdit:SetText("Error: Empty macro name")
            return
        end
        if self.active.source == "" then
            self.outputEdit:SetText("Error: Empty macro source")
            return
        end

        if self.active.key then
            if Core.customMacros[self.active.key] then -- update
                if self.active.key ~= self.active.name then
                    local macroId = GetMacroIndexByName(customMacro.active.key)
                    Core.customMacros[self.active.key] = nil -- remove previous key
                    self.active.key = self.active.name
                    Core.customMacros[self.active.key] = {}
                    if macroId > 0 then
                        EditMacro(macroId, self.active.key)
                    end
                end
                Core.customMacros[self.active.key].name = self.active.name
                Core.customMacros[self.active.key].source = self.active.source
                Core.customMacros[self.active.key].chunck = nil
                Core.customMacros[self.active.key].error = false
                Core.customMacros[self.active.key].body = nil
                Core.customMacros[self.active.key].icon = nil
                self.saved = true
            else -- insert
                Core.customMacros[self.active.key] = {}
                Core.customMacros[self.active.key].name = self.active.name
                Core.customMacros[self.active.key].source = self.active.source
                Core.customMacros[self.active.key].chunck = nil
                Core.customMacros[self.active.key].error = false
                Core.customMacros[self.active.key].body = nil
                Core.customMacros[self.active.key].icon = nil
                self.saved = true
            end
            Core:QueueScan()
        else -- insert
            self.active.key = self.active.name
            Core.customMacros[self.active.key] = {}
            Core.customMacros[self.active.key].name = self.active.name
            Core.customMacros[self.active.key].source = self.active.source
            Core.customMacros[self.active.key].chunck = nil
            Core.customMacros[self.active.key].error = false
            Core.customMacros[self.active.key].body = nil
            Core.customMacros[self.active.key].icon = nil
            self.saved = true
        end
    end

    customMacro:ui()
end

function customMacro:pickup()
    if customMacro.active and customMacro.active.key and customMacro.valid and customMacro.saved then
        local macroId = GetMacroIndexByName(customMacro.active.key)
        local acc, cha = GetNumMacros()
        if macroId and macroId > 0 then
            PickupMacro(macroId)
        elseif acc >= MAX_ACCOUNT_MACROS then
            Utility.Print("Unable to create the macro, you seam to have reach the maximum number of allowed macro per account.")
        else
            local macroId = CreateMacro(customMacro.active.key, "INV_Misc_Food_DimSum", "")
            if not InCombatLockdown() then
                Core:Scan()
            end
            PickupMacro(macroId)
        end
    else
        customMacro.outputEdit:SetText("Unable to proceed")
    end
end

function customMacro:checkName()
    local content = ""

    if self.active then
        local name = self.active.name
        if name ~= "" then
            if self.active.key then
                if self.active.key ~= name then --updating the name, check for duplicate
                    if Core.customMacros[name] or GetMacroIndexByName(name) > 0 then -- exists
                        content = "Invalid name: macro name already in used"
                        customMacro.outputEdit:SetText(content)
                        self.valid = false
                        return false
                    end
                end
            else
                if Core.customMacros[name] or GetMacroIndexByName(name) > 0 then -- exists
                    content = "Invalid name: macro name already in used"
                    customMacro.outputEdit:SetText(content)
                    self.valid = false
                    return false
                end
            end
        else
            content = "Invalid name: empty"
            customMacro.outputEdit:SetText(content)
            self.valid = false
            return false
        end
    end

    return true
end

function customMacro:checkSource()
    local content = ""

    if self.active then
        local source = self.active.source

        if source and source ~= "" then
            local chunck, errorMessage = loadstring(source, "customMacroCode")

            if chunck then
                content = "Compilation: OK"
                local success, ret = pcall(chunck, Core:BestsBeautifier(), Core.itemCache)
                if success then
                    content = (ret or "<nothing>")
                    customMacro.outputEdit:SetText(content)
                    self.valid = true
                    return true
                else
                    local error = ret:gsub("%[string \"customMacroCode\"%]:", "line ")
                    content = content .. ", Execution: FAILED, Error:\n" .. (error or "unknown")
                    customMacro.outputEdit:SetText(content)
                    self.valid = false
                    return false
                end
            else
                local error = errorMessage:gsub("%[string \"customMacroCode\"%]:", "line ")
                content = "Compilation: FAILED, Error:\n" .. error
                customMacro.outputEdit:SetText(content)
                self.valid = false
                return false
            end
        else
            content = "No source code to compile"
            customMacro.outputEdit:SetText(content)
            self.valid = false
            return false
        end
    else
        content = "No active macro"
        customMacro.outputEdit:SetText(content)
        self.valid = false
        return false
    end

    return true
end

function customMacro:checkAll()
    customMacro.outputEdit:SetText("")

    if customMacro:checkName() then
        customMacro:checkSource()
    end

    customMacro:ui()
end

local frame_custom = CreateFrame("Frame", nil, InterfaceOptionsFramePanelContainer)
frame_custom.name = "Custom Macros"
frame_custom.parent = "Buffet"
frame_custom.okay = function()
    customMacro:reset()
    Core:QueueScan()
end
frame_custom.cancel = function()
    customMacro:reset()
    Core:QueueScan()
end

frame_custom:Hide()
frame_custom:SetScript("OnShow", function()
    local title, subtitle = LibStub("tekKonfig-Heading").new(
        frame_custom,
        "Custom Macros",
        "This panel allows you to create custom macro using the lua language.\nHelp and macro examples here: https://github.com/HgAlexx/Buffet/wiki"
    )

    customMacro.buttonNew = tekbutt.new(frame_custom, "TOPLEFT", subtitle, "BOTTOMLEFT", 0, -GAP)
    customMacro.buttonNew:SetWidth(120)
    customMacro.buttonNew:SetText("New Macro")
    customMacro.buttonNew.tiptext = "Create a new macro"
    customMacro.buttonNew.name = "BuffetButtonNew"
    customMacro.buttonNew:SetScript("OnClick", function(self)
        customMacro:new()
    end)

    local menuMacro = CreateFrame("Frame", "BuffetMacroMenu", frame_custom, "UIDropDownMenuTemplate")
    customMacro.buttonLoad = tekbutt.new(frame_custom, "TOPRIGHT", subtitle, "BOTTOMRIGHT", -2, -GAP)
    customMacro.buttonLoad:SetWidth(120)
    customMacro.buttonLoad:SetText("Load Macro")
    customMacro.buttonLoad.tiptext = "Load an existing macro"
    customMacro.buttonLoad.name = "BuffetButtonLoad"
    customMacro.buttonLoad:SetScript("OnClick", function(self)
        ToggleDropDownMenu(1, nil, menuMacro, self, 0, 0)
    end)

    UIDropDownMenu_Initialize(menuMacro, function() customMacro:menu() end, "MENU");

    customMacro.nameEdit = largeEdit(frame_custom,
        customMacro.buttonNew,
        "Macro Name",
        "",
        "Name used by the macro",
        function(self)
            local value = self:GetText() or ""
            if customMacro.active then
                customMacro.active.name = Utility.Trim(value)
                customMacro:checkAll()
                customMacro:updateStatus()
                customMacro:ui()
            end
        end)
    customMacro.nameEdit:SetScript("OnTextChanged", function(self)
        local value = self:GetText() or ""
        if customMacro.active then
            customMacro.active.name = Utility.Trim(value)
            customMacro:checkAll()
            customMacro:updateStatus()
            customMacro:ui()
        end
    end)
    customMacro.nameEdit:Disable()

    customMacro.buttonDelete = tekbutt.new(frame_custom, "BOTTOMLEFT", frame_custom, "BOTTOMLEFT", EDGEGAP, EDGEGAP)
    customMacro.buttonDelete:SetWidth(120)
    customMacro.buttonDelete:SetText("Delete Macro")
    customMacro.buttonDelete.tiptext = "Delete macro"
    customMacro.buttonDelete.name = "BuffetButtonDelete"
    customMacro.buttonDelete:SetScript("OnClick", function(self)
        customMacro:delete()
    end)

    customMacro.buttonPick = tekbutt.new(frame_custom, "BOTTOMRIGHT", frame_custom, "BOTTOMRIGHT", -EDGEGAP, EDGEGAP)
    customMacro.buttonPick:SetWidth(120)
    customMacro.buttonPick:SetText("Pick Up Macro")
    customMacro.buttonPick.tiptext = "Pick Up macro"
    customMacro.buttonPick.name = "BuffetButtonPick"
    customMacro.buttonPick:SetScript("OnClick", function(self)
        customMacro:pickup()
    end)

    customMacro.buttonSave = tekbutt.new(frame_custom, "BOTTOMRIGHT", customMacro.buttonPick, "BOTTOMLEFT", -GAP, 0)
    customMacro.buttonSave:SetWidth(120)
    customMacro.buttonSave:SetText("Save Macro")
    customMacro.buttonSave.tiptext = "Save macro"
    customMacro.buttonSave.name = "BuffetButtonSave"
    customMacro.buttonSave:SetScript("OnClick", function(self)
        customMacro:save()
    end)


    customMacro.outputEdit = largeBottomEdit(frame_custom,
        customMacro.buttonDelete,
        "Output status",
        "",
        "Output status",
        function(self) end)
    customMacro.outputEdit:SetPoint("TOP", customMacro.buttonDelete, "TOP", 0, GAP + 3*16)
    customMacro.outputEdit:SetTextInsets(5, 5, 5, 5)
    customMacro.outputEdit:SetMultiLine(true)
    customMacro.outputEdit:SetAutoFocus(false)
    customMacro.outputEdit:SetText("")
    customMacro.outputEdit:Disable()

    customMacro.buttonCheck = tekbutt.new(frame_custom, "BOTTOMRIGHT", customMacro.outputEdit, "TOPRIGHT", 0, GAP)
    customMacro.buttonCheck:SetWidth(120)
    customMacro.buttonCheck:SetText("Check & Test")
    customMacro.buttonCheck.tiptext = "Check & Test Source Code"
    customMacro.buttonCheck.name = "BuffetButtonCheck"
    customMacro.buttonCheck:SetScript("OnClick", function(self)
        customMacro:checkAll()
    end)

    local sourceLabel = frame_custom:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
    sourceLabel:SetText("Macro Lua Source Code")
    sourceLabel:SetPoint("TOPLEFT", customMacro.nameEdit, "BOTTOMLEFT", 0, -GAP)

    local sourceFrame = CreateFrame("Frame", nil, frame_custom, BackdropTemplateMixin and "BackdropTemplate")
    sourceFrame:SetBackdrop(BACKDROP_TOOLTIP_12_12_4444)
    sourceFrame:SetBackdropColor(.1,.1,.1,.3)
    sourceFrame:SetPoint("TOPLEFT", sourceLabel, "BOTTOMLEFT", 0, -GAP)
    sourceFrame:SetPoint("RIGHT", frame_custom, "RIGHT", -EDGEGAP, 0)
    sourceFrame:SetPoint("BOTTOM", customMacro.buttonCheck, "TOP", 0, GAP)
    sourceFrame:EnableMouse(true)
    sourceFrame:SetScript("OnMouseDown", function (self, button)
        if button=='LeftButton' then
            customMacro.sourceEdit:SetFocus()
        end
    end)

    local scrollFrame = CreateFrame("ScrollFrame", nil, sourceFrame, "UIPanelScrollFrameTemplate")
    scrollFrame:SetPoint("TOPLEFT", sourceFrame, "TOPLEFT", 0, -3)
    scrollFrame:SetPoint("BOTTOMRIGHT", sourceFrame, "BOTTOMRIGHT", -25, 3)

    customMacro.sourceEdit = CreateFrame("EditBox", nil, frame_custom, BackdropTemplateMixin and "BackdropTemplate")
    customMacro.sourceEdit:SetMultiLine(true)
    customMacro.sourceEdit:SetMaxLetters(99999)
    customMacro.sourceEdit:EnableMouse(true)
    customMacro.sourceEdit:SetAutoFocus(false)
    customMacro.sourceEdit:SetFontObject(GameFontHighlight)
    customMacro.sourceEdit:SetTextInsets(5, 5, 5, 5)
    customMacro.sourceEdit:SetWidth(sourceFrame:GetWidth() - 20)
    scrollFrame:SetScrollChild(customMacro.sourceEdit)
    customMacro.sourceEdit:SetScript("OnEscapePressed", customMacro.sourceEdit.ClearFocus)
    customMacro.sourceEdit:SetScript("OnEditFocusLost", function(self)
        local value = self:GetText() or ""
        if customMacro.active then
            customMacro.active.source = Utility.Trim(value)
            customMacro:updateStatus()
            customMacro:ui()
        end
    end)
    customMacro.sourceEdit:SetScript("OnTextChanged", function(self)
        local value = self:GetText() or ""
        if customMacro.active then
            customMacro.active.source = Utility.Trim(value)
            customMacro.valid = false
            customMacro:updateStatus()
            customMacro:ui()
        end
    end)
    customMacro.sourceEdit:Disable()

    customMacro:reset()

    frame_custom:SetScript("OnEvent", function(self, event)
        if event == "PLAYER_REGEN_DISABLED" then
            customMacro:ui()
        end
        if event == "PLAYER_REGEN_ENABLED" then
            customMacro:ui()
        end
    end)
    frame_custom:RegisterEvent("PLAYER_REGEN_ENABLED")
    frame_custom:RegisterEvent("PLAYER_REGEN_DISABLED")

    frame_custom:SetScript("OnShow", function(self)
        frame_custom:RegisterEvent("PLAYER_REGEN_ENABLED")
        frame_custom:RegisterEvent("PLAYER_REGEN_DISABLED")
        customMacro:ui()
    end)

    frame_custom:SetScript("OnHide", function(self)
        frame_custom:UnregisterEvent("PLAYER_REGEN_ENABLED")
        frame_custom:UnregisterEvent("PLAYER_REGEN_DISABLED")
    end)
end)

InterfaceOptions_AddCategory(frame_custom)



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
