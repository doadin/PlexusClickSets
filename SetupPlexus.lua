local _, addon = ...
--addon.DependOn = CoreDependCall

if not addon.DependOn then
    local eventFrame = CreateFrame("Frame");
    local all_funcs = {}
    eventFrame:RegisterEvent("ADDON_LOADED")
    eventFrame:SetScript("OnEvent", function(self, event, addon)
        local funcs = all_funcs[addon]
        if not funcs then return end
        for i=#funcs, 1, -1 do
            funcs[i](event, addon)
        end
        all_funcs[addon] = nil
    end)

    addon.DependOn = function(addon, func)
        if(IsAddOnLoaded(addon)) then
            func()
        else
            all_funcs[addon] = all_funcs[addon] or {}
            table.insert(all_funcs[addon], func);
        end
    end
end

if select(5, GetAddOnInfo("Plexus")) == "MISSING" then
    return
end

addon.DependOn("Plexus", function()

    local PlexusFrame = Plexus:GetModule("PlexusFrame")

    local function WithAllPlexusFrames(func)
        for _, frame in pairs(PlexusFrame.registeredFrames) do
       		func(frame)
       	end
    end

    PlexusClickSets = Plexus:NewModule("PlexusClickSets")

    function PlexusFrameDropDown_Initialize(self)
        local unit = self:GetParent().unit;
        if ( not unit ) then
            return;
        end
        local menu;
        local name;
        local id = nil;
        if ( UnitIsUnit(unit, "player") ) then
            menu = "SELF";
        elseif ( UnitIsUnit(unit, "vehicle") ) then
            -- NOTE: vehicle check must come before pet check for accuracy's sake because
            -- a vehicle may also be considered your pet
            menu = "VEHICLE";
        elseif ( UnitIsUnit(unit, "pet") ) then
            menu = "PET";
        elseif ( UnitIsPlayer(unit) ) then
            id = UnitInRaid(unit);
            if ( id ) then
                menu = "RAID_PLAYER";
                name = GetRaidRosterInfo(id);
            elseif ( UnitInParty(unit) ) then
                menu = "PARTY";
            else
                menu = "PLAYER";
            end
        else
            menu = "TARGET";
            name = RAID_TARGET_ICON;
        end
        if ( menu ) then
            UnitPopup_ShowMenu(self, menu, unit, name, id);
        end
    end

    local function initializeFrame(plexusFrameObj, frame)
        frame.dropDown = CreateFrame("Frame", frame:GetName().."DropDown", frame, "UIDropDownMenuTemplate");
        frame.dropDown:SetPoint("TOPLEFT", frame, "BOTTOMLEFT", 0, 2);
        UIDropDownMenu_Initialize(frame.dropDown, PlexusFrameDropDown_Initialize, "MENU");
        frame.menu = function()
            ToggleDropDownMenu(1, nil, frame.dropDown, frame:GetName(), 0, 0);
        end
        frame:SetAttribute("*type2", "menu");
        frame.dropDown:Hide();
        PlexusClickSets_SetAttributes(frame, PlexusClickSetsFrame_GetCurrentSet());
    end

    hooksecurefunc(PlexusFrame, "InitializeFrame", initializeFrame)
    if IsLoggedIn() and PlexusFrame.registeredFrames then WithAllPlexusFrames(function(f) initializeFrame(nil, f) end) end

    local options = {
        type = "execute",
        name = PLEXUSCLICKSETS_MENUNAME,
        desc = PLEXUSCLICKSETS_MENUTIP,
        order = 0.1,
        func = function()
            --if InterfaceOptionsFrame:IsVisible() then
            --    InterfaceOptionsFrame.lastFrame = nil
            --    HideUIPanel(InterfaceOptionsFrame, true)
            --    PlexusClickSetsFrame.lastFrame = InterfaceOptionsFrame
            --else
            --    LibStub("AceConfigDialog-3.0"):Close("Plexus")
            --    PlexusClickSetsFrame.lastFrame = function() LibStub("AceConfigDialog-3.0"):Open("Plexus") end
            --end
            PlexusClickSetsFrame:Show();
            GameTooltip:Hide();
        end
    }

    PlexusClickSets.options = { type = "group", name = options.name, order = options.order, args = { button = options } }

    function PlexusClickSets:OnEnable()
        --the profile no longer work with plexus.
    end

    function PlexusClickSets:Reset()
        --the profile no longer work with plexus.
    end

    table.insert(PlexusClickSetsFrame_Updates, function(set)
        WithAllPlexusFrames(function (f) PlexusClickSets_SetAttributes(f, set) end)
    end);

end)
