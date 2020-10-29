local L = LibStub("AceLocale-3.0"):GetLocale("PlexusClickSets")
local PLEXUS_CLICK_SETS_BUTTONS = 5
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

function PlexusClickSetsFrame_OnLoad(self) --luacheck:ignore 111
    self:RegisterEvent("PLAYER_REGEN_ENABLED")
    self:RegisterEvent("VARIABLES_LOADED")
    self:RegisterEvent("PLAYER_SPECIALIZATION_CHANGED")
    self:RegisterEvent("PLAYER_ALIVE")
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

function PlexusClickSetsFrame_OnEvent(_, event, arg1) --luacheck:ignore 111
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

function PlexusClickSetsFrame_TypeUpdate(id) --luacheck:ignore 111
    local argF = getglobal("PlexusClickSetButton"..id.."Arg")
    local typeDD = getglobal("PlexusClickSetButton"..id.."Type")
    local value = UIDropDownMenu_GetSelectedValue(typeDD)
    if (not value) then value = "NONE" end

    if( value=="spell" or value=="macro" ) then
        argF:Show()
    else
        argF:Hide()
    end

    local below = getglobal("PlexusClickSetButton"..(id+1))
    if(below) then
        below:ClearAllPoints()
        if argF:IsVisible() then
            below:SetPoint("TOPLEFT", argF, "BOTTOMLEFT", -50, 0);
        else
            below:SetPoint("TOPLEFT", getglobal("PlexusClickSetButton"..id), "BOTTOMLEFT", 0, -5);
        end
    end
end

function PlexusClickSetsFrame_Resize() --luacheck:ignore 111
    local k=0
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

function PlexusClickSetsFrame_TypeUpdateAll() --luacheck:ignore 111
    for i=1,8 do
        PlexusClickSetsFrame_TypeUpdate(i)
    end
    PlexusClickSetsFrame_Resize()
end

function PlexusClickSets_Type_OnClick(self) --luacheck:ignore 111
    UIDropDownMenu_SetSelectedValue(self.owner, self.value)
    local id=self.owner:GetParent():GetID()
    PlexusClickSetsFrame_TypeUpdate(id)
    PlexusClickSetsFrame_Resize()
end

local function ddname(str)
    return " = "..str.." = "
end

function PlexusClickSetButton_TypeDropDown_Initialize(self) --luacheck:ignore 111
    local info

    local _, c = UnitClass("player")
    local spec = GetSpecialization()
    local list = PlexusClickSets_SpellList[c]
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
                    info.tooltipFunc = function(_, tip, arg1) tip:SetSpellByID(arg1) end
                    info.tooltipFuncArg1 = spellId
                    UIDropDownMenu_AddButton(info)
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

function PlexusClickSetsFrame_GetTabSet(btn) --luacheck:ignore 111
    local set = PlexusClickSetsFrame_GetCurrentSet()
    return set[tostring(btn)]
end

function PlexusClickSetsFrame_LoadSet(set) --luacheck:ignore 111
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

function PlexusClickSetsFrame_TabOnClick() --luacheck:ignore 111
    PlexusClickSetsFrame_LoadSet( PlexusClickSetsFrame_GetTabSet(PlexusClickSetsFrame.selectedTab) )
    if ( false and PlexusClickSetsFrame.selectedTab == 1 ) then
        UIDropDownMenu_SetSelectedValue(PlexusClickSetButton1Type, "target")
        UIDropDownMenu_DisableDropDown(PlexusClickSetButton1Type)
    else
        UIDropDownMenu_EnableDropDown(PlexusClickSetButton1Type)
    end
end

function PlexusClickSetsFrame_DefaultsOnClick(fromDialog) --luacheck:ignore 111
    if fromDialog == "YES" then
        local talent = GetSpecialization() or 1
        PlexusClickSetsForTalents[talent] = nil --luacheck:ignore 112
        PlexusClickSetsFrame_LoadSet( PlexusClickSetsFrame_GetTabSet(PlexusClickSetsFrame.selectedTab) )
        PlexusClickSetsFrame_ApplyOnClick()
    else
        StaticPopup_Show("PlexusClickSets_Reset")
    end
end

function PlexusClickSetsFrame_SaveOnClick() --luacheck:ignore 111
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

function PlexusClickSetsFrame_CancelOnClick() --luacheck:ignore 111
    PlexusClickSetsFrame_LoadSet( PlexusClickSetsFrame_GetTabSet(PlexusClickSetsFrame.selectedTab) )
end

function PlexusClickSetsFrame_CloseOnClick(_) --luacheck:ignore 111
    PlexusClickSetsFrame:Hide()
    local last = PlexusClickSetsFrame.lastFrame
    PlexusClickSetsFrame.lastFrame = nil --luacheck:ignore 112
    if last then
        if type(last) == "function" then
            last(PlexusClickSetsFrame)
        else
            last:Show()
        end
    end
end

function PlexusClickSetsFrame_ApplyOnClick() --luacheck:ignore 111
    PlexusClickSetsFrame_SaveOnClick()
    PlexusClickSetsFrame_UpdateAll()
    --PlexusClickSetsFrame:Hide()
end

PlexusClickSetsForTalents={} --luacheck:ignore 111
PlexusClickSetsFrame_Updates = {} --luacheck:ignore 111 --for other module insert

function PlexusClickSetsFrame_GetCurrentSet() --luacheck:ignore 111
    local spec = GetSpecialization() or 0
    if PlexusClickSetsFrame:IsVisible() then
        PlexusClickSetsFrameTalentText:SetFormattedText("%s: %s", SPECIALIZATION, select(2, GetSpecializationInfo(spec)) or UNKNOWN)
    end
    if PlexusClickSetsForTalents[spec]==nil then
        PlexusClickSetsForTalents[spec] = PlexusClickSets_GetDefault(spec) --luacheck:ignore 112
    end
    local set = PlexusClickSetsForTalents[spec]
    for i=1, PLEXUS_CLICK_SETS_BUTTONS+2 do set[tostring(i)] = set[tostring(i)] or {} end
    return set
end

function PlexusClickSetsFrame_UpdateAll(silent) --luacheck:ignore 111
    local set = PlexusClickSetsFrame_GetCurrentSet()
    if PlexusClickSetsFrame:IsVisible() then PlexusClickSetsFrame_TabOnClick() end
    if(InCombatLockdown()) then
        queue = true
        if not silent then DEFAULT_CHAT_FRAME:AddMessage(L["Can't set attributes during combat, settings will be applied later."], 1, 0, 0) end
    else
        for _, v in pairs(PlexusClickSetsFrame_Updates) do
            v(set)
        end
        if not silent then DEFAULT_CHAT_FRAME:AddMessage(L["Plexus Click Sets has been applied."], 1, 1, 0) end
    end
end

SLASH_CLICKSET1 = "/clicksets" --luacheck:ignore 111
SLASH_CLICKSET2 = "/pcs" --luacheck:ignore 111
SLASH_CLICKSET3 = "/plexusclicksets" --luacheck:ignore 111
SlashCmdList["CLICKSET"] = function(_)
    if PlexusClickSetsFrame:IsVisible() then PlexusClickSetsFrame:Hide() else PlexusClickSetsFrame:Show() end
end

StaticPopupDialogs['PlexusClickSets_Reset'] = {preferredIndex = 3, --luacheck:ignore 112
	text = L["All clickset for current specialization will lost!"],
	button1 = YES,
	button2 = NO,
	OnAccept = function(_) PlexusClickSetsFrame_DefaultsOnClick("YES") end,
	hideOnEscape = 1,
}
