local _, ns = ...
local L = ns.L
local button, db, toggleWindow, exportData
local ICON = "Interface\\AddOns\\GabbaProcTracker\\Assets\\Minimap.tga"

local function Position()
    local angle = math.rad(tonumber(db.minimapAngle) or 220)
    local radius = (Minimap:GetWidth() or 140) / 2 + 10
    button:ClearAllPoints()
    button:SetPoint("CENTER", Minimap, "CENTER", math.cos(angle) * radius, math.sin(angle) * radius)
end

function ns.RefreshMinimap()
    if not button then return end
    Position()
    button:SetShown(not db.minimapHidden)
end

function ns.InitMinimap(saved, toggle, export)
    db, toggleWindow, exportData = saved, toggle, export
    if not Minimap then return end
    if not button then
        button = CreateFrame("Button", "GabbaProcTrackerMinimapButton", Minimap)
        button:SetSize(32, 32)
        button:SetFrameStrata("MEDIUM")
        button:SetFrameLevel(Minimap:GetFrameLevel() + 8)
        button:RegisterForClicks("LeftButtonUp", "RightButtonUp")
        button:RegisterForDrag("LeftButton")
        local icon = button:CreateTexture(nil, "ARTWORK")
        icon:SetAllPoints()
        icon:SetTexture(ICON)
        -- The texture itself is circular RGBA, including its gold rim.
        button:SetHighlightTexture("Interface\\Minimap\\UI-Minimap-ZoomButton-Highlight", "ADD")
        button:SetScript("OnClick", function(self, mouse)
            if self.suppressUntil and GetTime() < self.suppressUntil then return end
            if mouse == "RightButton" then exportData() else toggleWindow() end
        end)
        button:SetScript("OnEnter", function(self)
            GameTooltip:SetOwner(self, "ANCHOR_LEFT")
            GameTooltip:SetText("GabbaProcTracker " .. ns.VERSION)
            GameTooltip:AddLine(L["Linksklick: Fenster oeffnen/schliessen"], 1, 1, 1)
            GameTooltip:AddLine(L["Rechtsklick: Export speichern"], 1, 1, 1)
            GameTooltip:AddLine(L["Ziehen: Position aendern"], 1, 1, 1)
            GameTooltip:Show()
        end)
        button:SetScript("OnLeave", function() GameTooltip:Hide() end)
        button:SetScript("OnDragStart", function(self)
            GameTooltip:Hide()
            self:SetScript("OnUpdate", function()
                local mx, my = Minimap:GetCenter()
                if not mx or not my then return end
                local x, y = GetCursorPosition()
                local scale = Minimap:GetEffectiveScale()
                db.minimapAngle = math.deg((math.atan2 or math.atan)(y / scale - my, x / scale - mx))
                Position()
            end)
        end)
        button:SetScript("OnDragStop", function(self)
            self:SetScript("OnUpdate", nil)
            self.suppressUntil = GetTime() + 0.2
        end)
        button:SetScript("OnHide", function(self)
            self:SetScript("OnUpdate", nil)
            GameTooltip:Hide()
        end)
    end
    ns.RefreshMinimap()
end
