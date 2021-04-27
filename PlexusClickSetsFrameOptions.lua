--newFrame = CreateFrame("frameType"[, "frameName"[, parentFrame[, "inheritsFrame"]]])
local mainframe = CreateFrame("Frame","PlexusClickSetButtonOptionTemplate", PlexusClickSetsFramePanelContainer)
mainframe:SetPoint('CENTER') -- x and y is pointless as they are both 0
mainframe:SetSize(450, 25) -- x = width, y = height
mainframe:SetToplevel(true)
--mainframe:SetFontObject('NumberFontNormalHuge')
--mainframe:SetJustifyH('CENTER')
--mainframe:SetInsertMode('TOP')
mainframe:Hide()

local mainframesub1 = CreateFrame("Frame",nil, PlexusClickSetButtonOptionTemplate, UIDropDownMenuTemplate)
mainframesub1:SetPoint('CENTER') -- x and y is pointless as they are both 0
mainframesub1:SetSize(450, 25) -- x = width, y = height
mainframesub1:SetToplevel(true)
--mainframesub1:SetFontObject('NumberFontNormalHuge')
--mainframesub1:SetJustifyH('CENTER')
--mainframesub1:SetInsertMode('TOP')
mainframesub1:Hide()

mainframesub1:SetScript('OnLoad', function()
    UIDropDownMenu_SetWidth(self, 270)
    UIDropDownMenu_Initialize(self, PlexusClickSetButton_TypeDropDown_Initialize)
    UIDropDownMenu_SetSelectedValue(self, "NONE")
    UIDropDownMenu_JustifyText(self, "LEFT")
end)

mainframesub1:SetScript('OnEnter', function()
    local value = UIDropDownMenu_GetSelectedValue(self)
    if type(value)=="string" then
        local _, _, spellId = value:find("spellId:([0-9]+)")
        if spellId then
            GameTooltip_SetDefaultAnchor(GameTooltip, self)
            GameTooltip:SetSpellByID(spellId)
            GameTooltip:Show()
        end
    end
end)

mainframesub1:SetScript('OnLeave', function()
    GameTooltip:Hide()
end)

local mainframesub1editbox = CreateFrame("EditBox","mainframesub1editbox", PlexusClickSetButtonOptionTemplate)
mainframesub1editbox:SetWidth(300)
mainframesub1editbox:SetHeight(150)
mainframesub1editbox:SetPoint("CENTER",UIParent)
mainframesub1editbox:SetTextInsets(6, 6, 6, 6)
mainframesub1editbox:SetMaxLetters(255)
local mainframesub1editboxbackdrop =
{
    bgFile = "",
    edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
    tile = true,
    tileSize = 16,
    edgeSize = 16,
    insets = { left = 3, right = 3, top = 3, bottom = 3 }
}
mainframesub1editbox:SetBackdrop(mainframesub1editboxbackdrop)
mainframesub1editbox:SetBackdropColor(0, 0, 0, .5)
mainframesub1editbox:Hide()

mainframesub1editbox:SetScript('OnEnterPressed', function()
    --if IsShiftKeyDown() or IsControlKeyDown() or IsAltKeyDown() then
    --    self:Insert("\n")
    --else
    --    self:ClearFocus()
    --    PlexusClickSetsFrame_ApplyOnClick()
    --end
end)

mainframesub1editbox:SetScript('OnEscapePressed', function()
    --self:ClearFocus()
end)

mainframesub1editbox:SetScript('OnTextChanged', function()
    --if UIDropDownMenu_GetSelectedValue(getglobal(self:GetParent():GetName().."Type")) == "spell" then
    --    local p = string.find(self:GetText(), "\n")
    --    if p then
    --        self:ClearFocus();
    --        local spell = string.sub(self:GetText(), 1, p-1);
    --        spell = tonumber(spell) and GetSpellInfo(tonumber(spell)) or spell;
    --        self:SetText(spell)
    --    end
    --end
    --PlexusClickSetsFrame_Resize()
end)

mainframesub1editbox:SetScript('OnTextChanged', function()
    --if UIDropDownMenu_GetSelectedValue(getglobal(self:GetParent():GetName().."Type")) == "spell" then
    --    local p = string.find(self:GetText(), "\n")
    --    if p then
    --        self:ClearFocus();
    --        local spell = string.sub(self:GetText(), 1, p-1);
    --        spell = tonumber(spell) and GetSpellInfo(tonumber(spell)) or spell;
    --        self:SetText(spell)
    --    end
    --end
    --PlexusClickSetsFrame_Resize()
end)

local PlexusClickSetsFrame = CreateFrame("Frame","PlexusClickSetsFrame", UIParent)
PlexusClickSetsFrame:SetPoint('CENTER') -- x and y is pointless as they are both 0
PlexusClickSetsFrame:SetSize(500, 520) -- x = width, y = height
PlexusClickSetsFrame:SetToplevel(true)
--PlexusClickSetsFrame:SetFontObject('NumberFontNormalHuge')
--PlexusClickSetsFrame:SetJustifyH('CENTER')
--PlexusClickSetsFrame:SetInsertMode('TOP')
PlexusClickSetsFrame:EnableMouse(true)
local PlexusClickSetsFramebackdrop =
{
    bgFile = "Interface\\ChatFrame\\ChatFrameBackground",
    edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
    tile = true,
    tileSize = 16,
    edgeSize = 16,
    insets = { left = 5, right = 5, top = 5, bottom = 5 }
}
PlexusClickSetsFrame:SetBackdrop(PlexusClickSetsFramebackdrop)
PlexusClickSetsFrame:SetBackdropColor(0, 0, 0, .5)
PlexusClickSetsFrame:Hide()

local PlexusClickSetsFrameCloseButton = CreateFrame("Button","PlexusClickSetsFrameCloseButton",PlexusClickSetsFrame, UIPanelButtonTemplate)
PlexusClickSetsFrameCloseButton:SetWidth(76)
PlexusClickSetsFrameCloseButton:SetHeight(22)
PlexusClickSetsFrameCloseButton:SetPoint('BOTTOMLEFT')
PlexusClickSetsFrameCloseButton:SetScript('OnClick', function()
    --PlexusClickSetsFrame_CloseOnClick(PlexusClickSetsFrameCloseButton)
end)
--PlexusClickSetsFrameCloseButton:Show()

local PlexusClickSetsFrameCancelButton = CreateFrame("Button","PlexusClickSetsFrameCancelButton",PlexusClickSetsFrame, UIPanelButtonTemplate)
PlexusClickSetsFrameCancelButton:SetWidth(76)
PlexusClickSetsFrameCancelButton:SetHeight(22)
PlexusClickSetsFrameCancelButton:SetPoint('BOTTOMLEFT',PlexusClickSetsFrameCloseButton)
PlexusClickSetsFrameCancelButton:SetScript('OnClick', function()
    PlexusClickSetsFrame_CancelOnClick()
end)
--PlexusClickSetsFrameCancelButton:Show()


local PlexusClickSetsFrameApplyButton = CreateFrame("Button","PlexusClickSetsFrameApplyButton",PlexusClickSetsFrame, UIPanelButtonTemplate)
PlexusClickSetsFrameApplyButton:SetWidth(76)
PlexusClickSetsFrameApplyButton:SetHeight(22)
PlexusClickSetsFrameApplyButton:SetPoint('BOTTOMLEFT',PlexusClickSetsFrameCancelButton)
PlexusClickSetsFrameApplyButton:SetScript('OnClick', function()
    PlexusClickSetsFrame_ApplyOnClick()
end)
--PlexusClickSetsFrameApplyButton:Show()

local PlexusClickSetsFrameDefaultsButton = CreateFrame("Button","PlexusClickSetsFrameDefaultsButton",PlexusClickSetsFrame, UIPanelButtonGrayTemplate)
PlexusClickSetsFrameDefaultsButton:SetWidth(76)
PlexusClickSetsFrameDefaultsButton:SetHeight(22)
PlexusClickSetsFrameDefaultsButton:SetPoint('BOTTOMLEFT',PlexusClickSetsFrameApplyButton)
PlexusClickSetsFrameDefaultsButton:SetScript('OnClick', function()
    PlexusClickSetsFrame_DefaultsOnClick()
end)
--PlexusClickSetsFrameDefaultsButton:Show()

local parentPanelContainer = CreateFrame("Frame","parentPanelContainer", UIParent)
parentPanelContainer:SetPoint('TOPLEFT') -- x and y is pointless as they are both 0
parentPanelContainer:SetSize(22, -50) -- x = width, y = height
parentPanelContainer:SetToplevel(true)
--PlexusClickSetsFrame:SetFontObject('NumberFontNormalHuge')
--PlexusClickSetsFrame:SetJustifyH('CENTER')
--PlexusClickSetsFrame:SetInsertMode('TOP')
parentPanelContainer:EnableMouse(true)
local parentPanelContainerbackdrop =
{
    bgFile = "",
    edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
    tile = true,
    tileSize = 16,
    edgeSize = 16,
    insets = { left = 5, right = 5, top = 5, bottom = 5 }
}
parentPanelContainer:SetBackdrop(parentPanelContainerbackdrop)
parentPanelContainer:Hide()

local parentTab1 = CreateFrame("Button","$parentTab1",parentPanelContainer, OptionsFrameTabButtonTemplate)
parentTab1:SetWidth(76)
parentTab1:SetHeight(22)
parentTab1:SetPoint('BOTTOMLEFT')
parentTab1:SetScript('OnClick', function()
    PlaySound(841);
    PlexusClickSetsFrame_SaveOnClick()
    PanelTemplates_Tab_OnClick(self, PlexusClickSetsFrame)
    PanelTemplates_UpdateTabs(PlexusClickSetsFrame)
    PlexusClickSetsFrame_TabOnClick()
end)
--parentTab1:Show()

local parentTab2 = CreateFrame("Button","$parentTab2",parentPanelContainer, OptionsFrameTabButtonTemplate)
parentTab2:SetWidth(76)
parentTab2:SetHeight(22)
parentTab2:SetPoint('BOTTOMLEFT')
parentTab2:SetScript('OnClick', function()
    PlaySound(841);
    PlexusClickSetsFrame_SaveOnClick()
    PanelTemplates_Tab_OnClick(self, PlexusClickSetsFrame)
    PanelTemplates_UpdateTabs(PlexusClickSetsFrame)
    PlexusClickSetsFrame_TabOnClick()
end)
--parentTab2:Show()

local parentTab3 = CreateFrame("Button","$parentTab3",parentPanelContainer, OptionsFrameTabButtonTemplate)
parentTab3:SetWidth(76)
parentTab3:SetHeight(22)
parentTab3:SetPoint('BOTTOMLEFT')
parentTab3:SetScript('OnClick', function()
    PlaySound(841);
    PlexusClickSetsFrame_SaveOnClick()
    PanelTemplates_Tab_OnClick(self, PlexusClickSetsFrame)
    PanelTemplates_UpdateTabs(PlexusClickSetsFrame)
    PlexusClickSetsFrame_TabOnClick()
end)
--parentTab3:Show()

local parentTab4 = CreateFrame("Button","$parentTab4",parentPanelContainer, OptionsFrameTabButtonTemplate)
parentTab4:SetWidth(76)
parentTab4:SetHeight(22)
parentTab4:SetPoint('BOTTOMLEFT')
parentTab4:SetScript('OnClick', function()
    PlaySound(841);
    PlexusClickSetsFrame_SaveOnClick()
    PanelTemplates_Tab_OnClick(self, PlexusClickSetsFrame)
    PanelTemplates_UpdateTabs(PlexusClickSetsFrame)
    PlexusClickSetsFrame_TabOnClick()
end)
--parentTab4:Show()

local parentTab5 = CreateFrame("Button","$parentTab5",parentPanelContainer, OptionsFrameTabButtonTemplate)
parentTab5:SetWidth(76)
parentTab5:SetHeight(22)
parentTab5:SetPoint('BOTTOMLEFT')
parentTab5:SetScript('OnClick', function()
    PlaySound(841);
    PlexusClickSetsFrame_SaveOnClick()
    PanelTemplates_Tab_OnClick(self, PlexusClickSetsFrame)
    PanelTemplates_UpdateTabs(PlexusClickSetsFrame)
    PlexusClickSetsFrame_TabOnClick()
end)
--parentTab5:Show()

local parentTab6 = CreateFrame("Button","$parentTab6",parentPanelContainer, OptionsFrameTabButtonTemplate)
parentTab6:SetWidth(76)
parentTab6:SetHeight(22)
parentTab6:SetPoint('BOTTOMLEFT')
parentTab6:SetScript('OnClick', function()
    PlaySound(841);
    PlexusClickSetsFrame_SaveOnClick()
    PanelTemplates_Tab_OnClick(self, PlexusClickSetsFrame)
    PanelTemplates_UpdateTabs(PlexusClickSetsFrame)
    PlexusClickSetsFrame_TabOnClick()
end)
--parentTab6:Show()

local parentTab7 = CreateFrame("Button","$parentTab7",parentPanelContainer, OptionsFrameTabButtonTemplate)
parentTab7:SetWidth(76)
parentTab7:SetHeight(22)
parentTab7:SetPoint('BOTTOMLEFT')
parentTab7:SetScript('OnClick', function()
    PlaySound(841);
    PlexusClickSetsFrame_SaveOnClick()
    PanelTemplates_Tab_OnClick(self, PlexusClickSetsFrame)
    PanelTemplates_UpdateTabs(PlexusClickSetsFrame)
    PlexusClickSetsFrame_TabOnClick()
end)
--parentTab7:Show()

local PlexusClickSetButton1 = CreateFrame("Frame","PlexusClickSetButton1", PlexusClickSetsFrame, PlexusClickSetButtonOptionTemplate, 1)
parentPanelContainer:SetPoint('TOPLEFT') -- x and y is pointless as they are both 0
parentPanelContainer:SetSize(22, -50) -- x = width, y = height
parentPanelContainer:SetToplevel(true)
--PlexusClickSetsFrame:SetFontObject('NumberFontNormalHuge')
--PlexusClickSetsFrame:SetJustifyH('CENTER')
--PlexusClickSetsFrame:SetInsertMode('TOP')
parentPanelContainer:EnableMouse(true)
local parentPanelContainerbackdrop =
{
    bgFile = "",
    edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
    tile = true,
    tileSize = 16,
    edgeSize = 16,
    insets = { left = 5, right = 5, top = 5, bottom = 5 }
}
parentPanelContainer:SetBackdrop(parentPanelContainerbackdrop)
parentPanelContainer:Hide()

local PlexusClickSetButton2 = CreateFrame("Button","PlexusClickSetButton2", PlexusClickSetsFrame, PlexusClickSetButtonOptionTemplate, 2)
PlexusClickSetButton2:SetScript('OnClick', function()
    PlexusClickSetsFrameClose:SetText(self.lastFrame and PREVIOUS or CLOSE)
    PlexusClickSetsFrame_TabOnClick()
end)
local PlexusClickSetButton3 = CreateFrame("Button","PlexusClickSetButton3", PlexusClickSetsFrame, PlexusClickSetButtonOptionTemplate, 3)
PlexusClickSetButton3:SetScript('OnClick', function()
    PlexusClickSetsFrameClose:SetText(self.lastFrame and PREVIOUS or CLOSE)
    PlexusClickSetsFrame_TabOnClick()
end)
local PlexusClickSetButton4 = CreateFrame("Button","PlexusClickSetButton4", PlexusClickSetsFrame, PlexusClickSetButtonOptionTemplate, 4)
PlexusClickSetButton4:SetScript('OnClick', function()
    PlexusClickSetsFrameClose:SetText(self.lastFrame and PREVIOUS or CLOSE)
    PlexusClickSetsFrame_TabOnClick()
end)
local PlexusClickSetButton5 = CreateFrame("Button","PlexusClickSetButton5", PlexusClickSetsFrame, PlexusClickSetButtonOptionTemplate, 5)
PlexusClickSetButton5:SetScript('OnClick', function()
    PlexusClickSetsFrameClose:SetText(self.lastFrame and PREVIOUS or CLOSE)
    PlexusClickSetsFrame_TabOnClick()
end)
local PlexusClickSetButton6 = CreateFrame("Button","PlexusClickSetButton6", PlexusClickSetsFrame, PlexusClickSetButtonOptionTemplate, 6)
PlexusClickSetButton6:SetScript('OnClick', function()
    PlexusClickSetsFrameClose:SetText(self.lastFrame and PREVIOUS or CLOSE)
    PlexusClickSetsFrame_TabOnClick()
end)
local PlexusClickSetButton7 = CreateFrame("Button","PlexusClickSetButton7", PlexusClickSetsFrame, PlexusClickSetButtonOptionTemplate, 7)
PlexusClickSetButton7:SetScript('OnClick', function()
    PlexusClickSetsFrameClose:SetText(self.lastFrame and PREVIOUS or CLOSE)
    PlexusClickSetsFrame_TabOnClick()
end)
local PlexusClickSetButton8 = CreateFrame("Button","PlexusClickSetButton8", PlexusClickSetsFrame, PlexusClickSetButtonOptionTemplate, 8)
PlexusClickSetButton8:SetScript('OnClick', function()
    PlexusClickSetsFrameClose:SetText(self.lastFrame and PREVIOUS or CLOSE)
    PlexusClickSetsFrame_TabOnClick()
end)