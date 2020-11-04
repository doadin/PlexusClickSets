local _, addon = ...
--addon.DependOn = CoreDependCall

if not addon.DependOn then
    local eventFrame = CreateFrame("Frame");
    local all_funcs = {}
    eventFrame:RegisterEvent("ADDON_LOADED")
    eventFrame:SetScript("OnEvent", function(self, event, addon) --luacheck:ignore 212 431
        local funcs = all_funcs[addon]
        if not funcs then return end
        for i=#funcs, 1, -1 do
            funcs[i](event, addon)
        end
        all_funcs[addon] = nil
    end)

    addon.DependOn = function(addon, func) --luacheck:ignore 431
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

    local function initializeFrame(plexusFrameObj, frame) --luacheck:ignore 212
        frame.dropDown = CreateFrame("Frame", frame:GetName().."DropDown", frame, "UIDropDownMenuTemplate");
        frame.dropDown:SetPoint("TOPLEFT", frame, "BOTTOMLEFT", 0, 2);
        UIDropDownMenu_Initialize(frame.dropDown, PlexusFrameDropDown_Initialize, "MENU");
        frame.menu = function()
            ToggleDropDownMenu(1, nil, frame.dropDown, frame:GetName(), 0, 0);
        end
        frame:SetAttribute("*type2", "menu");
        frame.dropDown:Hide();
        --PlexusClickSets_SetAttributes(frame, PlexusClickSetsFrame_GetCurrentSet());
    end

    hooksecurefunc(PlexusFrame, "InitializeFrame", initializeFrame)
    if IsLoggedIn() and PlexusFrame.registeredFrames then WithAllPlexusFrames(function(f) initializeFrame(nil, f) end) end

    --table.insert(
                    --PlexusClickSetsFrame_Updates,
                    --function(set)
                       --WithAllPlexusFrames(function (f) PlexusClickSets_SetAttributes(f, set) 
                    --end)
    --end)

end)
