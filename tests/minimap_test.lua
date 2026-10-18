local ROOT = (arg[0]:match("^(.*[/\\])") or "") .. "../"
local ns = {}
GetLocale = function() return "deDE" end
assert(loadfile(ROOT .. "Locale.lua"))("GabbaProcTracker", ns)
local now, cursorX, cursorY = 0, 400, 300
GetTime = function() return now end
GetCursorPosition = function() return cursorX, cursorY end
local methods = {}
function methods:SetScript(event, fn) self.scripts[event] = fn end
function methods:SetPoint(...) self.point = {...} end
function methods:SetShown(value)
    self.shown = value
    if not value and self.scripts.OnHide then self.scripts.OnHide(self) end
end
function methods:CreateTexture()
    return { SetAllPoints = function() end, SetTexture = function(_, value) self.texture = value end }
end
function CreateFrame(_, name)
    local frame = setmetatable({scripts = {}, suppressUntil = 0}, {__index = function(_, key) return methods[key] or function() end end})
    _G[name] = frame
    return frame
end
GameTooltip = setmetatable({}, {__index = function() return function() end end})
Minimap = {
    GetWidth = function() return 140 end, GetFrameLevel = function() return 2 end,
    GetCenter = function() return 100, 100 end, GetEffectiveScale = function() return 2 end,
}
assert(loadfile(ROOT .. "Minimap.lua"))("GabbaProcTracker", ns)
local db, opens, exports = {}, 0, 0
ns.InitMinimap(db, function() opens = opens + 1 end, function() exports = exports + 1 end)
local button = GabbaProcTrackerMinimapButton
assert(button.shown and button.texture:find("Assets\\Minimap.tga", 1, true))
button.scripts.OnClick(button, "LeftButton")
button.scripts.OnClick(button, "RightButton")
assert(opens == 1 and exports == 1)
button.scripts.OnDragStart(button)
button.scripts.OnUpdate()
assert(math.abs(db.minimapAngle - 26.565051177) < 0.0001)
local angle = db.minimapAngle
button.scripts.OnDragStop(button)
assert(button.scripts.OnUpdate == nil)
button.scripts.OnClick(button, "LeftButton")
assert(opens == 1) -- dropping the button does not open the tracker
now = 1
button.scripts.OnClick(button, "LeftButton")
assert(opens == 2)
db.minimapHidden = true
ns.RefreshMinimap()
assert(not button.shown)
ns.InitMinimap(db, function() end, function() end)
assert(not button.shown and db.minimapAngle == angle)
db.minimapHidden = false
ns.RefreshMinimap()
assert(button.shown)
print("PASS: minimap click/export, scale-aware dragging, drag-click suppression, saved position and visibility")
