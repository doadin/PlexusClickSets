local PLEXUSCLICKSETS, PlexusClickSets = ...
local LibStub = _G.LibStub
local AceConfig = LibStub("AceConfig-3.0")
local AceConfigCmd = LibStub:GetLibrary("AceConfigCmd-3.0")
local AceConfigDialog = LibStub("AceConfigDialog-3.0")
local AceGUI = LibStub("AceGUI-3.0")
local isClassic = (WOW_PROJECT_ID == WOW_PROJECT_CLASSIC)

_G.PlexusClickSets = LibStub("AceAddon-3.0"):NewAddon(PlexusClickSets, PLEXUSCLICKSETS,  "AceConsole-3.0", "AceEvent-3.0")

--local self.profileOptions = LibStub("AceDBOptions-3.0"):GetOptionsTable(self.db);

PlexusClickSets.defaultDB = {
    profile = {
        standaloneOptions = true,
        LeftMouseButton ={
            DirectClick = 1,
            CTRLClick = 1,
            ALTClick = 1,
            ShiftClick = 1,
            CTRLALTClick = 1,
            CTRLSHIFTClick = 1,
            SHIFTALTClick = 1,
            CTRLSHIFTALTClick = 1,
        },
        MiddleMouseButton ={
            DirectClick = 1,
            CTRLClick = 1,
            ALTClick = 1,
            ShiftClick = 1,
            CTRLALTClick = 1,
            CTRLSHIFTClick = 1,
            SHIFTALTClick = 1,
            CTRLSHIFTALTClick = 1,
        },
        RightMouseButton ={
            DirectClick = 1,
            CTRLClick = 1,
            ALTClick = 1,
            ShiftClick = 1,
            CTRLALTClick = 1,
            CTRLSHIFTClick = 1,
            SHIFTALTClick = 1,
            CTRLSHIFTALTClick = 1,
        },
    },
}

function PlexusClickSets:OnInitialize()
    print("OnInitialize")

    AceConfig:RegisterOptionsTable("PlexusClickSets", PlexusClickSets.myOptions)
    AceConfigDialog:AddToBlizOptions("PlexusClickSets", "PlexusClickSets")

    self.db = LibStub:GetLibrary("AceDB-3.0"):New("PlexusClickSetsDB", self.defaultDB, true)

    self.db.RegisterCallback(self, "OnProfileChanged", "OnProfileEnable")
    self.db.RegisterCallback(self, "OnProfileCopied", "OnProfileEnable")
    self.db.RegisterCallback(self, "OnProfileReset", "OnProfileEnable")

    self.myOptions.args.profile = LibStub:GetLibrary("AceDBOptions-3.0"):GetOptionsTable(self.db)
    self.myOptions.args.profile.order = -3
    if not isClassic then
        return
        --local LibDualSpec = LibStub:GetLibrary("LibDualSpec-1.0")
        --LibDualSpec:EnhanceDatabase(self.db, PLEXUS)
        --LibDualSpec:EnhanceOptions(self.options.args.profile, self.db)
    end

    LibStub:GetLibrary("AceConfigRegistry-3.0"):RegisterOptionsTable(PLEXUSCLICKSETS, self.options)

end

function PlexusClickSets:OnEnable()
    --self:Debug("OnEnable")
    print("OnEnable")

    if self.SetupOptions then
        self:SetupOptions()
    end

    --self:RegisterEvent("PLAYER_ENTERING_WORLD")
    --self:RegisterEvent("PLAYER_REGEN_DISABLED")
    --self:RegisterEvent("PLAYER_REGEN_ENABLED")

    --self:SendMessage("Plexus_Enabled")
end

function PlexusClickSets:OnProfileEnable()
    print("Loaded profile", self.db:GetCurrentProfile())
end

function PlexusClickSets:SetupOptions()
    print("SetupOptions")
    self:RegisterChatCommand("plexusclicksets", function(input)
        if input then
            input = strtrim(input)
        end
        if not input or input == "" then
            self:ToggleOptions()
        elseif strmatch(strlower(input), "^ve?r?s?i?o?n?$") then
            local version = GetAddOnMetadata(PLEXUS, "Version")
            if version == "@" .. "project-version" .. "@" then -- concatenation to trick the packager
                self:Print("You are using a developer version.") -- no need to localize
            else
                self:Print("You are using a developer version.") -- no need to localize
            end
        else
            AceConfigCmd.HandleCommand(PlexusClickSets, "plexusclicksets", PLEXUSCLICKSETS, input)
        end
    end)

    InterfaceOptionsFrame:HookScript("OnShow", function()
        AceConfigDialog:Close(PLEXUSCLICKSETS)
    end)
end

function PlexusClickSets:ToggleOptions()
    print("ToggleOptions")
    if self.db.profile.standaloneOptions then
        print("Standalone")
        local Dialog = LibStub:GetLibrary("AceConfigDialog-3.0")
        if Dialog.OpenFrames[PLEXUSCLICKSETS] then
            Dialog:Close(PLEXUSCLICKSETS)
        else
            Dialog:Open(PLEXUSCLICKSETS)
        end
    else
        InterfaceOptionsFrame_OpenToCategory("PlexusClickSets") -- default to Layout
        InterfaceOptionsFrame_OpenToCategory("PlexusClickSets") -- double up as a workaround for the bug that opens the frame without selecting the panel
    end
end

PlexusClickSets.myOptions = {
    type = "group",
    childGroups = "tab",
    get = function(info)
        local k = info[#info]
        return PlexusClickSets.db.profile[k]
    end,
    set = function(info, v)
        local k = info[#info]
        PlexusClickSets.db.profile[k] = v
    end,
    args = {
        standaloneOptions = {
            name = "Enable standaloneOptions",
            desc = "Enables / disables standaloneOptions",
            type = "toggle",
        },
        LeftMouseButton={
            name = "Left Mouse Button",
            type = "group",
            order = 1,
            get = function(info)
                local k = info[#info]
                return PlexusClickSets.db.profile.LeftMouseButton[k]
            end,
            set = function(info, v)
                local k = info[#info]
                PlexusClickSets.db.profile.LeftMouseButton[k] = v
            end,
            args={
                DirectClick = {
                    name = "Direct Click",
                    desc = "Enables / disables the addon",
                    type = "select",
                    order = 1,
                    values = {"None", "Target", "Assist", "Macro", "Spell Name"},
                },
                DirectClickSpellName = {
                    name = "Spell Name",
                    desc = "Enables / disables the addon",
                    type = "input",
                    order = 2,
                    hidden = function()
                        if PlexusClickSets.db.profile.LeftMouseButton.DirectClick ~= 5 then
                            return true
                        end
                    end,
                },
                DirectClickMacro = {
                    name = "Macro",
                    desc = "Enables / disables the addon",
                    type = "input",
                    order = 3,
                    hidden = function()
                        if PlexusClickSets.db.profile.LeftMouseButton.DirectClick ~= 4 then
                            return true
                        end
                    end,
                },
                StatusesHeader1 = {
                    type = "header",
                    name = "",
                    order = 4,
                },
                CTRLClick = {
                    name = "Ctrl + Click",
                    desc = "Enables / disables the addon",
                    type = "select",
                    order = 5,
                    values = {"None", "Target", "Assist", "Macro", "Spell Name"},
                },
                CTRLClickSpellName = {
                    name = "Spell Name",
                    desc = "Enables / disables the addon",
                    type = "input",
                    order = 6,
                    hidden = function()
                        if PlexusClickSets.db.profile.LeftMouseButton.CTRLClick ~= 5 then
                            return true
                        end
                    end,
                },
                CTRLClickMacro = {
                    name = "Macro",
                    desc = "Enables / disables the addon",
                    type = "input",
                    order = 7,
                    hidden = function()
                        if PlexusClickSets.db.profile.LeftMouseButton.CTRLClick ~= 4 then
                            return true
                        end
                    end,
                },
                StatusesHeader2 = {
                    type = "header",
                    name = "",
                    order = 8,
                },
                ALTClick = {
                    name = "Alt + Click",
                    desc = "Enables / disables the addon",
                    type = "select",
                    order = 9,
                    values = {"None", "Target", "Assist", "Macro", "Spell Name"},
                },
                ALTClickSpellName = {
                    name = "Spell Name",
                    desc = "Enables / disables the addon",
                    type = "input",
                    order = 10,
                    hidden = function()
                        if PlexusClickSets.db.profile.LeftMouseButton.ALTClick ~= 5 then
                            return true
                        end
                    end,
                },
                ALTClickMacro = {
                    name = "Macro",
                    desc = "Enables / disables the addon",
                    type = "input",
                    order = 11,
                    hidden = function()
                        if PlexusClickSets.db.profile.LeftMouseButton.ALTClick ~= 4 then
                            return true
                        end
                    end,
                },
                StatusesHeader3 = {
                    type = "header",
                    name = "",
                    order = 12,
                },
                ShiftClick = {
                    name = "Shift + Click",
                    desc = "Enables / disables the addon",
                    type = "select",
                    order = 13,
                    values = {"None", "Target", "Assist", "Macro", "Spell Name"},
                },
                ShiftClickSpellName = {
                    name = "Spell Name",
                    desc = "Enables / disables the addon",
                    type = "input",
                    order = 14,
                    hidden = function()
                        if PlexusClickSets.db.profile.LeftMouseButton.ShiftClick ~= 5 then
                            return true
                        end
                    end,
                },
                ShiftClickMacro = {
                    name = "Macro",
                    desc = "Enables / disables the addon",
                    type = "input",
                    order = 15,
                    hidden = function()
                        if PlexusClickSets.db.profile.LeftMouseButton.ShiftClick ~= 4 then
                            return true
                        end
                    end,
                },
                StatusesHeader4 = {
                    type = "header",
                    name = "",
                    order = 16,
                },
                CTRLALTClick = {
                    name = "Ctrl + Alt + Click",
                    desc = "Enables / disables the addon",
                    type = "select",
                    order = 17,
                    values = {"None", "Target", "Assist", "Macro", "Spell Name"},
                },
                CTRLALTClickSpellName = {
                    name = "Spell Name",
                    desc = "Enables / disables the addon",
                    type = "input",
                    order = 18,
                    hidden = function()
                        if PlexusClickSets.db.profile.LeftMouseButton.CTRLALTClick ~= 5 then
                            return true
                        end
                    end,
                },
                CTRLALTClickMacro = {
                    name = "Macro",
                    desc = "Enables / disables the addon",
                    type = "input",
                    order = 19,
                    hidden = function()
                        if PlexusClickSets.db.profile.LeftMouseButton.CTRLALTClick ~= 4 then
                            return true
                        end
                    end,
                },
                StatusesHeader5 = {
                    type = "header",
                    name = "",
                    order = 20,
                },
                CTRLSHIFTClick = {
                    name = "Ctrl + Shift + Click",
                    desc = "Enables / disables the addon",
                    type = "select",
                    order = 21,
                    values = {"None", "Target", "Assist", "Macro", "Spell Name"},
                },
                CTRLSHIFTClickSpellName = {
                    name = "Spell Name",
                    desc = "Enables / disables the addon",
                    type = "input",
                    order = 22,
                    hidden = function()
                        if PlexusClickSets.db.profile.LeftMouseButton.CTRLSHIFTClick ~= 5 then
                            return true
                        end
                    end,
                },
                CTRLSHIFTClickMacro = {
                    name = "Macro",
                    desc = "Enables / disables the addon",
                    type = "input",
                    order = 23,
                    hidden = function()
                        if PlexusClickSets.db.profile.LeftMouseButton.CTRLSHIFTClick ~= 4 then
                            return true
                        end
                    end,
                },
                StatusesHeader6 = {
                    type = "header",
                    name = "",
                    order = 24,
                },
                SHIFTALTClick = {
                    name = "Shift + Alt + Click",
                    desc = "Enables / disables the addon",
                    type = "select",
                    order = 25,
                    values = {"None", "Target", "Assist", "Macro", "Spell Name"},
                },
                SHIFTALTClickSpellName = {
                    name = "Spell Name",
                    desc = "Enables / disables the addon",
                    type = "input",
                    order = 26,
                    hidden = function()
                        if PlexusClickSets.db.profile.LeftMouseButton.SHIFTALTClick ~= 5 then
                            return true
                        end
                    end,
                },
                SHIFTALTClickMacro = {
                    name = "Macro",
                    desc = "Enables / disables the addon",
                    type = "input",
                    order = 27,
                    hidden = function()
                        if PlexusClickSets.db.profile.LeftMouseButton.SHIFTALTClick ~= 4 then
                            return true
                        end
                    end,
                },
                StatusesHeader7 = {
                    type = "header",
                    name = "",
                    order = 28,
                },
                CTRLSHIFTALTClick = {
                    name = "Ctrl + Shift + Alt + Click",
                    desc = "Enables / disables the addon",
                    type = "select",
                    order = 29,
                    values = {"None", "Target", "Assist", "Macro", "Spell Name"},
                },
                CTRLSHIFTALTClickSpellName = {
                    name = "Spell Name",
                    desc = "Enables / disables the addon",
                    type = "input",
                    order = 30,
                    hidden = function()
                        if PlexusClickSets.db.profile.LeftMouseButton.CTRLSHIFTALTClick ~= 5 then
                            return true
                        end
                    end,
                },
                CTRLSHIFTALTClickMacro = {
                    name = "Macro",
                    desc = "Enables / disables the addon",
                    type = "input",
                    order = 31,
                    hidden = function()
                        if PlexusClickSets.db.profile.LeftMouseButton.CTRLSHIFTALTClick ~= 4 then
                            return true
                        end
                    end,
                },
            },
        },
        RightMouseButton={
            name = "Right Mouse Button",
            type = "group",
            order = 3,
            get = function(info)
                local k = info[#info]
                return PlexusClickSets.db.profile.RightMouseButton[k]
            end,
            set = function(info, v)
                local k = info[#info]
                PlexusClickSets.db.profile.RightMouseButton[k] = v
            end,
            args={
                DirectClick = {
                    name = "Direct Click",
                    desc = "Enables / disables the addon",
                    type = "select",
                    order = 1,
                    values = {"None", "Target", "Assist", "Macro", "Spell Name"},
                },
                DirectClickSpellName = {
                    name = "Spell Name",
                    desc = "Enables / disables the addon",
                    type = "input",
                    order = 2,
                    hidden = function()
                        if PlexusClickSets.db.profile.RightMouseButton.DirectClick ~= 5 then
                            return true
                        end
                    end,
                },
                DirectClickMacro = {
                    name = "Macro",
                    desc = "Enables / disables the addon",
                    type = "input",
                    order = 3,
                    hidden = function()
                        if PlexusClickSets.db.profile.RightMouseButton.DirectClick ~= 4 then
                            return true
                        end
                    end,
                },
                StatusesHeader1 = {
                    type = "header",
                    name = "",
                    order = 4,
                },
                CTRLClick = {
                    name = "Ctrl + Click",
                    desc = "Enables / disables the addon",
                    type = "select",
                    order = 5,
                    values = {"None", "Target", "Assist", "Macro", "Spell Name"},
                },
                CTRLClickSpellName = {
                    name = "Spell Name",
                    desc = "Enables / disables the addon",
                    type = "input",
                    order = 6,
                    hidden = function()
                        if PlexusClickSets.db.profile.RightMouseButton.CTRLClick ~= 5 then
                            return true
                        end
                    end,
                },
                CTRLClickMacro = {
                    name = "Macro",
                    desc = "Enables / disables the addon",
                    type = "input",
                    order = 7,
                    hidden = function()
                        if PlexusClickSets.db.profile.RightMouseButton.CTRLClick ~= 4 then
                            return true
                        end
                    end,
                },
                StatusesHeader2 = {
                    type = "header",
                    name = "",
                    order = 8,
                },
                ALTClick = {
                    name = "Alt + Click",
                    desc = "Enables / disables the addon",
                    type = "select",
                    order = 9,
                    values = {"None", "Target", "Assist", "Macro", "Spell Name"},
                },
                ALTClickSpellName = {
                    name = "Spell Name",
                    desc = "Enables / disables the addon",
                    type = "input",
                    order = 10,
                    hidden = function()
                        if PlexusClickSets.db.profile.RightMouseButton.ALTClick ~= 5 then
                            return true
                        end
                    end,
                },
                ALTClickMacro = {
                    name = "Macro",
                    desc = "Enables / disables the addon",
                    type = "input",
                    order = 11,
                    hidden = function()
                        if PlexusClickSets.db.profile.RightMouseButton.ALTClick ~= 4 then
                            return true
                        end
                    end,
                },
                StatusesHeader3 = {
                    type = "header",
                    name = "",
                    order = 12,
                },
                ShiftClick = {
                    name = "Shift + Click",
                    desc = "Enables / disables the addon",
                    type = "select",
                    order = 13,
                    values = {"None", "Target", "Assist", "Macro", "Spell Name"},
                },
                ShiftClickSpellName = {
                    name = "Spell Name",
                    desc = "Enables / disables the addon",
                    type = "input",
                    order = 14,
                    hidden = function()
                        if PlexusClickSets.db.profile.RightMouseButton.ShiftClick ~= 5 then
                            return true
                        end
                    end,
                },
                ShiftClickMacro = {
                    name = "Macro",
                    desc = "Enables / disables the addon",
                    type = "input",
                    order = 15,
                    hidden = function()
                        if PlexusClickSets.db.profile.RightMouseButton.ShiftClick ~= 4 then
                            return true
                        end
                    end,
                },
                StatusesHeader4 = {
                    type = "header",
                    name = "",
                    order = 16,
                },
                CTRLALTClick = {
                    name = "Ctrl + Alt + Click",
                    desc = "Enables / disables the addon",
                    type = "select",
                    order = 17,
                    values = {"None", "Target", "Assist", "Macro", "Spell Name"},
                },
                CTRLALTClickSpellName = {
                    name = "Spell Name",
                    desc = "Enables / disables the addon",
                    type = "input",
                    order = 18,
                    hidden = function()
                        if PlexusClickSets.db.profile.RightMouseButton.CTRLALTClick ~= 5 then
                            return true
                        end
                    end,
                },
                CTRLALTClickMacro = {
                    name = "Macro",
                    desc = "Enables / disables the addon",
                    type = "input",
                    order = 19,
                    hidden = function()
                        if PlexusClickSets.db.profile.RightMouseButton.CTRLALTClick ~= 4 then
                            return true
                        end
                    end,
                },
                StatusesHeader5 = {
                    type = "header",
                    name = "",
                    order = 20,
                },
                CTRLSHIFTClick = {
                    name = "Ctrl + Shift + Click",
                    desc = "Enables / disables the addon",
                    type = "select",
                    order = 21,
                    values = {"None", "Target", "Assist", "Macro", "Spell Name"},
                },
                CTRLSHIFTClickSpellName = {
                    name = "Spell Name",
                    desc = "Enables / disables the addon",
                    type = "input",
                    order = 22,
                    hidden = function()
                        if PlexusClickSets.db.profile.RightMouseButton.CTRLSHIFTClick ~= 5 then
                            return true
                        end
                    end,
                },
                CTRLSHIFTClickMacro = {
                    name = "Macro",
                    desc = "Enables / disables the addon",
                    type = "input",
                    order = 23,
                    hidden = function()
                        if PlexusClickSets.db.profile.RightMouseButton.CTRLSHIFTClick ~= 4 then
                            return true
                        end
                    end,
                },
                StatusesHeader6 = {
                    type = "header",
                    name = "",
                    order = 24,
                },
                SHIFTALTClick = {
                    name = "Shift + Alt + Click",
                    desc = "Enables / disables the addon",
                    type = "select",
                    order = 25,
                    values = {"None", "Target", "Assist", "Macro", "Spell Name"},
                },
                SHIFTALTClickSpellName = {
                    name = "Spell Name",
                    desc = "Enables / disables the addon",
                    type = "input",
                    order = 26,
                    hidden = function()
                        if PlexusClickSets.db.profile.RightMouseButton.SHIFTALTClick ~= 5 then
                            return true
                        end
                    end,
                },
                SHIFTALTClickMacro = {
                    name = "Macro",
                    desc = "Enables / disables the addon",
                    type = "input",
                    order = 27,
                    hidden = function()
                        if PlexusClickSets.db.profile.RightMouseButton.SHIFTALTClick ~= 4 then
                            return true
                        end
                    end,
                },
                StatusesHeader7 = {
                    type = "header",
                    name = "",
                    order = 28,
                },
                CTRLSHIFTALTClick = {
                    name = "Ctrl + Shift + Alt + Click",
                    desc = "Enables / disables the addon",
                    type = "select",
                    order = 29,
                    values = {"None", "Target", "Assist", "Macro", "Spell Name"},
                },
                CTRLSHIFTALTClickSpellName = {
                    name = "Spell Name",
                    desc = "Enables / disables the addon",
                    type = "input",
                    order = 30,
                    hidden = function()
                        if PlexusClickSets.db.profile.RightMouseButton.CTRLSHIFTALTClick ~= 5 then
                            return true
                        end
                    end,
                },
                CTRLSHIFTALTClickMacro = {
                    name = "Macro",
                    desc = "Enables / disables the addon",
                    type = "input",
                    order = 31,
                    hidden = function()
                        if PlexusClickSets.db.profile.RightMouseButton.CTRLSHIFTALTClick ~= 4 then
                            return true
                        end
                    end,
                },
            },
        },
        MiddleMouseButton={
            name = "Middle Mouse Button",
            type = "group",
            order = 2,
            get = function(info)
                local k = info[#info]
                return PlexusClickSets.db.profile.MiddleMouseButton[k]
            end,
            set = function(info, v)
                local k = info[#info]
                PlexusClickSets.db.profile.MiddleMouseButton[k] = v
            end,
            args={
                DirectClick = {
                    name = "Direct Click",
                    desc = "Enables / disables the addon",
                    type = "select",
                    order = 1,
                    values = {"None", "Target", "Assist", "Macro", "Spell Name"},
                },
                DirectClickSpellName = {
                    name = "Spell Name",
                    desc = "Enables / disables the addon",
                    type = "input",
                    order = 2,
                    hidden = function()
                        if PlexusClickSets.db.profile.MiddleMouseButton.DirectClick ~= 5 then
                            return true
                        end
                    end,
                },
                DirectClickMacro = {
                    name = "Macro",
                    desc = "Enables / disables the addon",
                    type = "input",
                    order = 3,
                    hidden = function()
                        if PlexusClickSets.db.profile.MiddleMouseButton.DirectClick ~= 4 then
                            return true
                        end
                    end,
                },
                StatusesHeader1 = {
                    type = "header",
                    name = "",
                    order = 4,
                },
                CTRLClick = {
                    name = "Ctrl + Click",
                    desc = "Enables / disables the addon",
                    type = "select",
                    order = 5,
                    values = {"None", "Target", "Assist", "Macro", "Spell Name"},
                },
                CTRLClickSpellName = {
                    name = "Spell Name",
                    desc = "Enables / disables the addon",
                    type = "input",
                    order = 6,
                    hidden = function()
                        if PlexusClickSets.db.profile.MiddleMouseButton.CTRLClick ~= 5 then
                            return true
                        end
                    end,
                },
                CTRLClickMacro = {
                    name = "Macro",
                    desc = "Enables / disables the addon",
                    type = "input",
                    order = 7,
                    hidden = function()
                        if PlexusClickSets.db.profile.MiddleMouseButton.CTRLClick ~= 4 then
                            return true
                        end
                    end,
                },
                StatusesHeader2 = {
                    type = "header",
                    name = "",
                    order = 8,
                },
                ALTClick = {
                    name = "Alt + Click",
                    desc = "Enables / disables the addon",
                    type = "select",
                    order = 9,
                    values = {"None", "Target", "Assist", "Macro", "Spell Name"},
                },
                ALTClickSpellName = {
                    name = "Spell Name",
                    desc = "Enables / disables the addon",
                    type = "input",
                    order = 10,
                    hidden = function()
                        if PlexusClickSets.db.profile.MiddleMouseButton.ALTClick ~= 5 then
                            return true
                        end
                    end,
                },
                ALTClickMacro = {
                    name = "Macro",
                    desc = "Enables / disables the addon",
                    type = "input",
                    order = 11,
                    hidden = function()
                        if PlexusClickSets.db.profile.MiddleMouseButton.ALTClick ~= 4 then
                            return true
                        end
                    end,
                },
                StatusesHeader3 = {
                    type = "header",
                    name = "",
                    order = 12,
                },
                ShiftClick = {
                    name = "Shift + Click",
                    desc = "Enables / disables the addon",
                    type = "select",
                    order = 13,
                    values = {"None", "Target", "Assist", "Macro", "Spell Name"},
                },
                ShiftClickSpellName = {
                    name = "Spell Name",
                    desc = "Enables / disables the addon",
                    type = "input",
                    order = 14,
                    hidden = function()
                        if PlexusClickSets.db.profile.MiddleMouseButton.ShiftClick ~= 5 then
                            return true
                        end
                    end,
                },
                ShiftClickMacro = {
                    name = "Macro",
                    desc = "Enables / disables the addon",
                    type = "input",
                    order = 15,
                    hidden = function()
                        if PlexusClickSets.db.profile.MiddleMouseButton.ShiftClick ~= 4 then
                            return true
                        end
                    end,
                },
                StatusesHeader4 = {
                    type = "header",
                    name = "",
                    order = 16,
                },
                CTRLALTClick = {
                    name = "Ctrl + Alt + Click",
                    desc = "Enables / disables the addon",
                    type = "select",
                    order = 17,
                    values = {"None", "Target", "Assist", "Macro", "Spell Name"},
                },
                CTRLALTClickSpellName = {
                    name = "Spell Name",
                    desc = "Enables / disables the addon",
                    type = "input",
                    order = 18,
                    hidden = function()
                        if PlexusClickSets.db.profile.MiddleMouseButton.CTRLALTClick ~= 5 then
                            return true
                        end
                    end,
                },
                CTRLALTClickMacro = {
                    name = "Macro",
                    desc = "Enables / disables the addon",
                    type = "input",
                    order = 19,
                    hidden = function()
                        if PlexusClickSets.db.profile.MiddleMouseButton.CTRLALTClick ~= 4 then
                            return true
                        end
                    end,
                },
                StatusesHeader5 = {
                    type = "header",
                    name = "",
                    order = 20,
                },
                CTRLSHIFTClick = {
                    name = "Ctrl + Shift + Click",
                    desc = "Enables / disables the addon",
                    type = "select",
                    order = 21,
                    values = {"None", "Target", "Assist", "Macro", "Spell Name"},
                },
                CTRLSHIFTClickSpellName = {
                    name = "Spell Name",
                    desc = "Enables / disables the addon",
                    type = "input",
                    order = 22,
                    hidden = function()
                        if PlexusClickSets.db.profile.MiddleMouseButton.CTRLSHIFTClick ~= 5 then
                            return true
                        end
                    end,
                },
                CTRLSHIFTClickMacro = {
                    name = "Macro",
                    desc = "Enables / disables the addon",
                    type = "input",
                    order = 23,
                    hidden = function()
                        if PlexusClickSets.db.profile.MiddleMouseButton.CTRLSHIFTClick ~= 4 then
                            return true
                        end
                    end,
                },
                StatusesHeader6 = {
                    type = "header",
                    name = "",
                    order = 24,
                },
                SHIFTALTClick = {
                    name = "Shift + Alt + Click",
                    desc = "Enables / disables the addon",
                    type = "select",
                    order = 25,
                    values = {"None", "Target", "Assist", "Macro", "Spell Name"},
                },
                SHIFTALTClickSpellName = {
                    name = "Spell Name",
                    desc = "Enables / disables the addon",
                    type = "input",
                    order = 26,
                    hidden = function()
                        if PlexusClickSets.db.profile.MiddleMouseButton.SHIFTALTClick ~= 5 then
                            return true
                        end
                    end,
                },
                SHIFTALTClickMacro = {
                    name = "Macro",
                    desc = "Enables / disables the addon",
                    type = "input",
                    order = 27,
                    hidden = function()
                        if PlexusClickSets.db.profile.MiddleMouseButton.SHIFTALTClick ~= 4 then
                            return true
                        end
                    end,
                },
                StatusesHeader7 = {
                    type = "header",
                    name = "",
                    order = 28,
                },
                CTRLSHIFTALTClick = {
                    name = "Ctrl + Shift + Alt + Click",
                    desc = "Enables / disables the addon",
                    type = "select",
                    order = 29,
                    values = {"None", "Target", "Assist", "Macro", "Spell Name"},
                },
                CTRLSHIFTALTClickSpellName = {
                    name = "Spell Name",
                    desc = "Enables / disables the addon",
                    type = "input",
                    order = 30,
                    hidden = function()
                        if PlexusClickSets.db.profile.MiddleMouseButton.CTRLSHIFTALTClick ~= 5 then
                            return true
                        end
                    end,
                },
                CTRLSHIFTALTClickMacro = {
                    name = "Macro",
                    desc = "Enables / disables the addon",
                    type = "input",
                    order = 31,
                    hidden = function()
                        if PlexusClickSets.db.profile.MiddleMouseButton.CTRLSHIFTALTClick ~= 4 then
                            return true
                        end
                    end,
                },
            },
        },
    }
}

