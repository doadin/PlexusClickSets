--local L = LibStub("AceLocale-3.0"):GetLocale("PlexusClickSets")
local function IsClassicWow()
	return WOW_PROJECT_ID == WOW_PROJECT_CLASSIC
end

local function IsTBCWow()
	return WOW_PROJECT_ID == WOW_PROJECT_BURNING_CRUSADE_CLASSIC
end

local function IsRetailWow()
	return WOW_PROJECT_ID == WOW_PROJECT_MAINLINE
end
local i
local queue = false

local function makeMovable(frame)
    local mover = _G[frame:GetName() .. "Mover"] or CreateFrame("Frame", frame:GetName() .. "Mover", frame)
    mover:EnableMouse(true)
    mover:SetPoint("TOP", frame, "TOP", 0, 10)
    mover:SetWidth(160)
    mover:SetHeight(40)
    mover:SetScript("OnMouseDown", function(self)
        self:GetParent():StartMoving()
    end)
    mover:SetScript("OnMouseUp", function(self)
        self:GetParent():StopMovingOrSizing()
    end)
    -- mover:SetClampedToScreen(true)		-- doesn't work?
    frame:SetMovable(true)
end

function PlexusClickSetsFrame_OnLoad(self)
    self:RegisterEvent("PLAYER_REGEN_ENABLED")
    self:RegisterEvent("VARIABLES_LOADED")
    if IsRetailWow() then
        self:RegisterEvent("PLAYER_SPECIALIZATION_CHANGED")
    end
    self:RegisterEvent("PLAYER_ALIVE")
    self:SetBackdrop({
        bgFile = "Interface\\DialogFrame\\UI-DialogBox-Background",
        edgeFile = "Interface\\DialogFrame\\UI-DialogBox-Border",
        tile = true,
        tileEdge = true,
        tileSize = 32,
        edgeSize = 32,
        insets = { left = 11, right = 11, top = 12, bottom = 10 },
    })

    makeMovable(self)
    PanelTemplates_SetNumTabs(self, PLEXUS_CLICK_SETS_BUTTONS + 2)
    self.selectedTab = 1
    PanelTemplates_UpdateTabs(self)

    for i = 1, 8 do
        getglobal("PlexusClickSetButton"..i.."Title"):SetText(PlexusClickSets_Titles[i])
    end

    --PlexusClickSetsFrame_TabOnClick()
    table.insert(UISpecialFrames, self:GetName())
end

function PlexusClickSetsFrame_OnEvent(self, event, arg1)
    if(event=="PLAYER_REGEN_ENABLED") then
        if(queue) then
            PlexusClickSetsFrame_UpdateAll()
            queue = false
        end
    elseif(event=="VARIABLES_LOADED") then
        if not U1 then
            if(GetLocale()=="zhCN") then
                DEFAULT_CHAT_FRAME:AddMessage("PlexusClickSets - |cffff3333爱不易|r (github.com/aby-ui)")
            elseif(GetLocale()=="zhTW") then
                DEFAULT_CHAT_FRAME:AddMessage("PlexusClickSets - |cff3399FF三月十二|r@聖光之願|cffFF00FF<冰封十字軍>|r.")
            end
        else
            if _G.ClassMods and _G.ClassMods.Options.DB.clicktocast.enabled then
                U1Message("ClassMods的ClickToCast模块和有爱点击施法冲突，请关闭")
            end
        end
    end

    if(event=="VARIABLES_LOADED" or (event=="PLAYER_SPECIALIZATION_CHANGED" and arg1=="player") or event=="PLAYER_ALIVE") then
        PlexusClickSetsFrame_UpdateAll(1)
    end
end

function PlexusClickSetsFrame_TypeUpdate(id)
    local argF = getglobal("PlexusClickSetButton"..id.."Arg")
    local typeDD = getglobal("PlexusClickSetButton"..id.."Type")
    local value = UIDropDownMenu_GetSelectedValue(typeDD)
    if (not value) then value = "NONE" end

    argF:SetBackdrop({
        bgFile = "Interface/Tooltips/UI-Tooltip-Background",
        edgeFile = "Interface/Tooltips/UI-Tooltip-Border",
        edgeSize = 16,
        insets = { left = 4, right = 4, top = 4, bottom = 4 },
    })
    argF:SetBackdropColor(0, 0, 0, .5)

    if( value=="spell" or value=="macro" ) then
        argF:Show()
    else
        argF:Hide()
    end

    local below = getglobal("PlexusClickSetButton"..(id+1))
    if(below) then
        below:ClearAllPoints()
        if argF:IsVisible() then
            below:SetPoint("TOPLEFT", argF, "BOTTOMLEFT", -50, 0)
        else
            below:SetPoint("TOPLEFT", getglobal("PlexusClickSetButton"..id), "BOTTOMLEFT", 0, -5)
        end
    end
end

function PlexusClickSetsFrame_Resize()
    local k=0
    local id
    for id=1, 8 do
        local argF = getglobal("PlexusClickSetButton"..id.."Arg")
        if(argF:IsVisible()) then
            k = k + argF:GetHeight() + 1
        end
    end
    local height = 340 + k
    if(height > 450) then
        PlexusClickSetsFrame:SetHeight(height)
    else
        PlexusClickSetsFrame:SetHeight(450)
    end
end

function PlexusClickSetsFrame_TypeUpdateAll()
    for i=1,8 do
        PlexusClickSetsFrame_TypeUpdate(i)
    end
    PlexusClickSetsFrame_Resize()
end

function PlexusClickSets_Type_OnClick(self)
    UIDropDownMenu_SetSelectedValue(self.owner, self.value)
    local id=self.owner:GetParent():GetID()
    PlexusClickSetsFrame_TypeUpdate(id)
    PlexusClickSetsFrame_Resize()
end

local function ddname(str)
    return " = "..str.." = "
end

function PlexusClickSetButton_TypeDropDown_Initialize(self)
    local info
    local spec
    local _, c = UnitClass("player")
    if IsRetailWow() then
        spec = GetSpecialization()
    end
    if IsClassicWow() then
        spec = 0
    end
    if IsTBCWow() then
        spec = 0
    end
    local list
    if PlexusClickSets_SpellList then
        list = PlexusClickSets_SpellList[c]
        if(list) then
            for spellId, defSpec in pairs(list) do
                --ReplacingTalentSpell IsKnown = false, Replaced IsKnown = true
                if PlexusClickSets_MayHaveSpell(defSpec, spec) then
                    local name, _, icon = GetSpellInfo(spellId)
                    if name ~= nil then
                        info = {}
                        info.text = name
                        info.icon = icon
                        info.owner = self
                        info.func = PlexusClickSets_Type_OnClick
                        info.value = "spellId:"..spellId
                        info.tooltipFunc = function(self, tip, arg1) tip:SetSpellByID(arg1) end
                        info.tooltipFuncArg1 = spellId
                        UIDropDownMenu_AddButton(info)
                    end
                end
            end
        end
    end

    info = {}
    info.text = ddname(TARGET)
    info.owner = self
    info.func = PlexusClickSets_Type_OnClick
    info.value = "target"
    UIDropDownMenu_AddButton(info)

    info = {}
    info.text = ddname(BINDING_NAME_ASSISTTARGET)
    info.owner = self
    info.func = PlexusClickSets_Type_OnClick
    info.value = "assist"
    UIDropDownMenu_AddButton(info)

    info = {}
    info.text = ddname(SKILL..NAME)
    info.owner = self
    info.func = PlexusClickSets_Type_OnClick
    info.value = "spell"
    UIDropDownMenu_AddButton(info)

    --	info = {}
    --	info.text = ddname(SOCIAL_LABEL)
    --	info.owner = self
    --	info.func = PlexusClickSets_Type_OnClick
    --	info.value = "menu"
    --	UIDropDownMenu_AddButton(info)

    info = {}
    info.text = ddname(MACRO)
    info.owner = self
    info.func = PlexusClickSets_Type_OnClick
    info.value = "macro"
    UIDropDownMenu_AddButton(info)

    info = {}
    info.text = NONE --ddname(NONE)
    info.owner = self
    info.func = PlexusClickSets_Type_OnClick
    info.value = "NONE"
    UIDropDownMenu_AddButton(info)
end

function PlexusClickSetsFrame_GetTabSet(btn)
    local set = PlexusClickSetsFrame_GetCurrentSet()
    return set[tostring(btn)]
end

function PlexusClickSetsFrame_LoadSet(set)
    for i = 1, 8 do
        local dd = getglobal("PlexusClickSetButton"..i.."Type")
        local atts = set and set[PlexusClickSets_Modifiers[i]] or {}
        UIDropDownMenu_Initialize(dd, PlexusClickSetButton_TypeDropDown_Initialize)
        UIDropDownMenu_SetSelectedValue(dd, atts.type or "NONE")
        if(atts.arg) then
            getglobal("PlexusClickSetButton"..i.."Arg"):SetText(atts.arg)
        else
            getglobal("PlexusClickSetButton"..i.."Arg"):SetText("")
        end
    end

    PlexusClickSetsFrame_TypeUpdateAll()
end

function PlexusClickSetsFrame_TabOnClick()
    PlexusClickSetsFrame_LoadSet( PlexusClickSetsFrame_GetTabSet(PlexusClickSetsFrame.selectedTab) )
    if ( false and PlexusClickSetsFrame.selectedTab == 1 ) then
        UIDropDownMenu_SetSelectedValue(PlexusClickSetButton1Type, "target")
        UIDropDownMenu_DisableDropDown(PlexusClickSetButton1Type)
    else
        UIDropDownMenu_EnableDropDown(PlexusClickSetButton1Type)
    end
end

function PlexusClickSetsFrame_DefaultsOnClick(fromDialog)
    if IsRetailWow() then
        if fromDialog == "YES" then
            local talent = GetSpecialization() or 1
            PlexusClickSetsForTalents[talent] = nil
            PlexusClickSetsFrame_LoadSet( PlexusClickSetsFrame_GetTabSet(PlexusClickSetsFrame.selectedTab) )
            PlexusClickSetsFrame_ApplyOnClick()
        else
            StaticPopup_Show("PlexusClickSets_Reset")
        end
    end
end

function PlexusClickSetsFrame_SaveOnClick()
    local set = PlexusClickSetsFrame_GetCurrentSet()
    for i=1,8 do
        set[tostring(PlexusClickSetsFrame.selectedTab)][PlexusClickSets_Modifiers[i]] = {
            type = UIDropDownMenu_GetSelectedValue( getglobal("PlexusClickSetButton"..i.."Type") ),
            arg = getglobal("PlexusClickSetButton"..i.."Arg"):GetText()
        }

        if set[tostring(PlexusClickSetsFrame.selectedTab)][PlexusClickSets_Modifiers[i]].arg == "" then
            set[tostring(PlexusClickSetsFrame.selectedTab)][PlexusClickSets_Modifiers[i]].arg = nil
        end

        if set[tostring(PlexusClickSetsFrame.selectedTab)][PlexusClickSets_Modifiers[i]].type == "NONE" then
            set[tostring(PlexusClickSetsFrame.selectedTab)][PlexusClickSets_Modifiers[i]] = nil
        end
    end
end

function PlexusClickSetsFrame_CancelOnClick()
    PlexusClickSetsFrame_LoadSet( PlexusClickSetsFrame_GetTabSet(PlexusClickSetsFrame.selectedTab) )
end

function PlexusClickSetsFrame_CloseOnClick(self)
    PlexusClickSetsFrame:Hide()
    local last = PlexusClickSetsFrame.lastFrame
    PlexusClickSetsFrame.lastFrame = nil
    if last then
        if type(last) == "function" then
            last(PlexusClickSetsFrame)
        else
            last:Show()
        end
    end
end

function PlexusClickSetsFrame_ApplyOnClick()
    PlexusClickSetsFrame_SaveOnClick()
    PlexusClickSetsFrame_UpdateAll()
    --PlexusClickSetsFrame:Hide()
end

PlexusClickSetsForTalents={}
PlexusClickSetsFrame_Updates = {} --for other module insert

function PlexusClickSetsFrame_GetCurrentSet()
    local spec = 0
    local set = {}
    if IsRetailWow() then
        spec = GetSpecialization() or 0
        if PlexusClickSetsFrame:IsVisible() then
            PlexusClickSetsFrameTalentText:SetFormattedText("%s: %s", SPECIALIZATION, select(2, GetSpecializationInfo(spec)) or UNKNOWN)
        end
        if PlexusClickSetsForTalents[spec]==nil then
            PlexusClickSetsForTalents[spec] = PlexusClickSets_GetDefault(spec)
        end
        set = PlexusClickSetsForTalents[spec]
        for i=1, PLEXUS_CLICK_SETS_BUTTONS+2 do
            set[tostring(i)] = set[tostring(i)] or {}
        end
    end
    if IsClassicWow() or IsTBCWow() then
        spec = 0
        if PlexusClickSetsForTalents[spec]==nil then
            PlexusClickSetsForTalents[spec] = PlexusClickSets_GetDefault(spec)
        end
        set = PlexusClickSetsForTalents[spec]
        for i=1, PLEXUS_CLICK_SETS_BUTTONS+2 do
            set[tostring(i)] = set[tostring(i)] or {}
        end
    end
    return set
end

function PlexusClickSetsFrame_UpdateAll(silent)
    local set = PlexusClickSetsFrame_GetCurrentSet()
    if PlexusClickSetsFrame:IsVisible() then PlexusClickSetsFrame_TabOnClick() end
    if(InCombatLockdown()) then
        queue = true
        if not silent then DEFAULT_CHAT_FRAME:AddMessage(PLEXUSCLICKSETS_LOCKWARNING, 1, 0, 0) end
    else
        for _, v in pairs(PlexusClickSetsFrame_Updates) do
            v(set)
        end
        if not silent then DEFAULT_CHAT_FRAME:AddMessage(PLEXUSCLICKSETS_SET, 1, 1, 0) end
    end
end

SLASH_CLICKSET1 = "/clicksets"
SLASH_CLICKSET2 = "/pcs"
SLASH_CLICKSET3 = "/plexusclicksets"
SlashCmdList["CLICKSET"] = function(msg)
    if PlexusClickSetsFrame:IsVisible() then PlexusClickSetsFrame:Hide() else PlexusClickSetsFrame:Show() end
end

StaticPopupDialogs['PlexusClickSets_Reset'] = {preferredIndex = 3,
	text = PLEXUSCLICKSETS_SET_RESET_WARNING,
	button1 = YES,
	button2 = NO,
	OnAccept = function(self) PlexusClickSetsFrame_DefaultsOnClick("YES") end,
	hideOnEscape = 1,
}
