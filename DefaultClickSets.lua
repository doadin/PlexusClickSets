--/run for _, v in pairs(PlexusClickSets_DefaultSets) do for _, v2 in pairs(v) do for _, v3 in next, v2 do if not GetSpellInfo(v3) then print(v3, GetSpellInfo(v3)) end end end end
local PLEXUS_CLICK_SETS_BUTTONS = 5 --max buttons, another 2 more for wheel up & wheel down
local assist = { type = "assist" }


PlexusClickSets_Modifiers = { --luacheck:ignore 111
    "",
    "ctrl-",
    "alt-",
    "shift-",
    "alt-ctrl-",
    "ctrl-shift-",
    "alt-shift-",
    "alt-ctrl-shift-",
}

local secureHeader = CreateFrame("Frame", nil, UIParent, "SecureHandlerBaseTemplate")

function PlexusClickSets_SetAttributes(frame, set) --luacheck:ignore 111
    set = set

    for i=1,PLEXUS_CLICK_SETS_BUTTONS do
        --local btn = set[tostring(i)] or {};
        for j=1,8 do
            local modi = PlexusClickSets_Modifiers[j]
            --local set = btn[modi] or {}

            PlexusClickSets_SetAttribute(frame, i, modi, set.type, set.arg)
        end
    end

    -- for wheel up/down bindings (new on 11.02.22)
    local binded = 0
    local script = "self:ClearBindings()";
    for i=1,2 do
        --local btn = set[tostring(PLEXUS_CLICK_SETS_BUTTONS+i)] or {};
        for j=1,8 do
            local modi = PlexusClickSets_Modifiers[j]
            --local set = btn[modi]
            if(set) then
                binded = binded + 1
                script = script.."self:SetBindingClick(1, \""..modi..(i==1 and "MOUSEWHEELUP" or "MOUSEWHEELDOWN").."\", self, \"Button"..(PLEXUS_CLICK_SETS_BUTTONS+binded).."\")"
                PlexusClickSets_SetAttribute(frame, PLEXUS_CLICK_SETS_BUTTONS+binded, "", set.type, set.arg)
            end
        end
    end

    secureHeader:UnwrapScript(frame, "OnEnter")
    secureHeader:WrapScript(frame, "OnEnter", script);
    secureHeader:UnwrapScript(frame, "OnLeave")
    secureHeader:WrapScript(frame, "OnLeave", "self:ClearBindings()");
end

function PlexusClickSets_SetAttribute(frame, button, modi, type, arg) --luacheck:ignore 211
    --if InCombatLockdown() then return end

    if(type==nil or type=="NONE") then
        frame:SetAttribute(modi.."type"..button, nil)
        frame:SetAttribute(modi.."macrotext"..button, nil)
        frame:SetAttribute(modi.."spell"..button, nil)
        return
    elseif strsub(type, 1, 8) == "spellId:" then
        frame:SetAttribute(modi.."type"..button, "spell")
        frame:SetAttribute(modi.."spell"..button, select(1, GetSpellInfo(strsub(type, 9))))
        return
    end

    frame:SetAttribute(modi.."type"..button, type)
    if type == "spell" then
        frame:SetAttribute(modi.."spell"..button, arg)
    elseif type == "macro" then
        local unit = SecureButton_GetModifiedUnit(frame, modi.."unit"..button)
        if unit and arg then
            arg = string.gsub(arg, "##", unit)
        else
            arg = arg and string.gsub(arg, "##", "@mouseover")
        end
        frame:SetAttribute(modi.."macrotext"..button, arg)
    end
end
