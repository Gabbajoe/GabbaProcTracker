local ROOT = (arg[0]:match("^(.*[/\\])") or "") .. "../"
GetLocale = function() return arg[1] or "deDE" end
local ns = {}
assert(loadfile(ROOT .. "Locale.lua"))("GabbaProcTracker", ns)
assert(loadfile(ROOT .. "Tracker.lua"))("GabbaProcTracker", ns)
assert(loadfile(ROOT .. "Catalog.lua"))("GabbaProcTracker", ns)
assert(loadfile(ROOT .. "Export.lua"))("GabbaProcTracker", ns)
local db = {}
local t = ns.NewTracker(db)
local function record(event, id, context, source, dest, time)
    return t:Record(time or 1, event, source or "me", dest or "me", "me", id, "Spell " .. id, context, function() return true end)
end
assert(record("SPELL_AURA_APPLIED", 20007, "world"))
assert(record("SPELL_AURA_REFRESH", 20007, "party"))
assert(record("SPELL_AURA_APPLIED", 20007, "raid"))
assert(db.counts[20007].world == 1 and db.counts[20007].instance == 2)
assert(db.counts[20007].context_party == 1 and db.counts[20007].context_raid == 1)
assert(not record("SPELL_AURA_APPLIED_DOSE", 20007, "world"))
assert(not record("SPELL_AURA_APPLIED", 20007, "world", "other"))
assert(not record("SPELL_AURA_APPLIED", 20007, "world", "me", "other"))
assert(record("SPELL_DAMAGE", 20004, "world"))
assert(not record("SPELL_HEAL", 20004, "world"))
assert(not record("SPELL_DAMAGE", 13897, "world", "other"))
assert(record("SPELL_MISSED", 13897, "world"))
assert(record("SPELL_EXTRA_ATTACKS", 15600, "party"))
assert(not record("SPELL_CAST_SUCCESS", 15600, "party"))
assert(record("SPELL_DAMAGE", 6296, "world", "me", "target1", 5))
assert(not record("SPELL_DAMAGE", 6296, "world", "me", "target2", 5))
assert(record("SPELL_DAMAGE", 6296, "world", "me", "target1", 6))
assert(not t:Record(7, "SPELL_DAMAGE", "me", "target", "me", 13897, "Fire", "world", function() return false end))
assert(record("SPELL_AURA_APPLIED", 16551, "world"))
assert(record("SPELL_AURA_REFRESH", 16551, "party"))
assert(not record("SPELL_AURA_REMOVED", 16551, "world"))
assert(not record("SPELL_DAMAGE", 16551, "world"))
assert(record("SPELL_EXTRA_ATTACKS", 15494, "raid"))
assert(not record("SWING_DAMAGE", 15494, "raid"))
assert(not record("SPELL_CAST_SUCCESS", 15494, "raid"))
assert(db.counts[15494].context_raid == 1)
assert(record("SPELL_DAMAGE", 18211, "world"))
assert(record("SPELL_MISSED", 18211, "world"))
assert(not record("SPELL_DAMAGE", 18211, "world", "other"))
assert(record("SPELL_DAMAGE", 18817, "party"))
assert(not record("SPELL_HEAL", 18817, "party"))
assert(record("SPELL_DAMAGE", 18818, "party", "me", "target1", 20))
assert(not record("SPELL_DAMAGE", 18818, "party", "me", "target2", 20))
assert(not record("SPELL_MISSED", 18818, "party", "me", "target3", 20))
assert(record("SPELL_DAMAGE", 18818, "party", "me", "target1", 21))
assert(db.counts[18818].context_party == 2)
assert(db.counts[18817].name == "Schaedelflammenschild: Lebensentzug")
t:Reset()
t:Begin("world", "Elwynn", 10, "now", function(effect) return effect.enchant == 1900 end)
assert(record("SPELL_AURA_APPLIED", 20007, "world"))
local rate, seconds, procs = t:Rate(20007, "world", 40)
assert(rate == 2 and seconds == 30 and procs == 1)
t:Finish(70)
assert(t:Rate(20007, "world", 100) == 1)
t:Begin("party", "Deadmines", 100, "later", function(effect) return effect.enchant == 1900 end)
t:Finish(220)
local dungeonRate, dungeonSeconds = t:Rate(20007, "party", 220)
assert(dungeonRate == 0 and dungeonSeconds == 120) -- zero-proc fights included
assert(t:Rate(13897, "party", 220) == nil) -- unequipped time excluded
assert(#db.history == 2 and db.history[1].zone == "Elwynn")
local csv = ns.ExportCSV(t, "counts", 'Test;"Name', 220)
assert(csv:find('"Test;""Name"', 1, true))
assert(csv:find('"Dungeon";"20007";"Spell 20007";"0";"0";"120.000";"0.000000"', 1, true))
local historyCSV = ns.ExportCSV(t, "history", "Test", 220)
assert(historyCSV:find('"Deadmines";"20007";"Spell 20007";"120.000";"0";"0.000000"', 1, true))
t:Begin("raid", 'Zone;"test"', 220, "now", function(effect) return effect.enchant == 1900 end)
local activeCSV = ns.ExportCSV(t, "history", "=Test", 250)
assert(activeCSV:find('"\'=Test"', 1, true))
assert(activeCSV:find('"' .. ns.L["laufend"] .. '";"Raid";"Zone;""test"""', 1, true))
assert(t.session and #db.history == 2)
t:Finish(220)
print("PASS: CSV escaping, zero-proc rows, live snapshot without mutation")
local restored = ns.NewTracker(db)
assert(restored:Rate(20007, "world", 999) == 1)
for i = 1, 310 do
    restored:Begin("raid", "Raid", i, "test", function() return true end)
    restored:Finish(i + 1)
end
assert(#db.history == 300)
assert(db.stats.raid[20007].seconds == 310) -- history retention doesn't erase totals
restored:Reset()
assert(next(db.counts) == nil and next(db.stats) == nil and #db.history == 0)
print("PASS: filters, contexts, duplicate prevention, combat exposure, zero-proc fights, persistence, retention, reset")

-- Load the real UI/event controller with a minimal WoW API test harness.
local frames = {}
local methods = {}
function methods:SetScript(name, fn) self.scripts[name] = fn end
function methods:SetText(text) self.text = text end
function methods:GetText() return self.text end
function methods:IsShown() return self.shown end
function methods:Show() self.shown = true; if self.scripts.OnShow then self.scripts.OnShow(self) end end
function methods:Hide() self.shown = false end
function methods:SetShown(value) if value then self:Show() else self:Hide() end end
local function frame()
    return setmetatable({ scripts = {}, shown = true }, { __index = function(_, key) return methods[key] or function() end end })
end
function methods:CreateFontString() return frame() end
function CreateFrame(_, name)
    local f = frame()
    f.TitleText = frame()
    frames[#frames + 1] = f
    if name then _G[name] = f end
    return f
end
UIParent = frame()
UISpecialFrames, SlashCmdList = {}, {}
tinsert = table.insert
DEFAULT_CHAT_FRAME = { AddMessage = function() end }
date = function() return "18.10.2026 12:00" end
local now, inCombat, area = 0, false, "none"
GetTime = function() return now end
UnitAffectingCombat = function() return inCombat end
UnitGUID = function() return "me" end
UnitName = function() return "Tester" end
GetRealmName = function() return "TestRealm" end
IsInInstance = function() return area ~= "none", area end
GetRealZoneText = function() return "Test Zone" end
GetInventoryItemID = function(_, slot) return slot == 13 and 11815 or nil end
GetInventoryItemLink = function(_, slot) return slot == 16 and "item:123:1900:0" or nil end
assert(loadfile(ROOT .. "Minimap.lua"))("GabbaProcTracker", ns)
assert(loadfile(ROOT .. "Core.lua"))("GabbaProcTracker", ns)
local controller = frames[1]
local function event(name, ...) controller.scripts.OnEvent(controller, name, ...) end
event("ADDON_LOADED", "GabbaProcTracker")
event("PLAYER_ENTERING_WORLD")
SlashCmdList.GABBAPROCTRACKER("")
inCombat = true
event("PLAYER_REGEN_DISABLED")
CombatLogGetCurrentEventInfo = function() return 1, "SPELL_AURA_APPLIED", false, "me", nil, nil, nil, "me", nil, nil, nil, 20007, "Crusader" end
event("COMBAT_LOG_EVENT_UNFILTERED")
now = 60
inCombat = false
event("PLAYER_REGEN_ENABLED")
assert(GabbaProcTrackerDB.stats.world[20007].seconds == 60)
assert(GabbaProcTrackerDB.counts[20007].context_world == 1)
for _, command in ipairs({ "rates", "history", "counts", "list", "export", "export history", "csv", "csv history", "add 999 buff", "remove 999", "help" }) do
    SlashCmdList.GABBAPROCTRACKER(command)
end
local exportSequence = GabbaProcTrackerDB.exportSequence
GabbaProcTrackerExportButton.scripts.OnClick()
assert(GabbaProcTrackerDB.exportSequence == exportSequence + 1)
assert(GabbaProcTrackerDB.export.characterId == GabbaProcTrackerDB.characterId)
for _, context in ipairs({ "party", "raid" }) do
    area, inCombat = context, true
    event("PLAYER_ENTERING_WORLD")
    event("COMBAT_LOG_EVENT_UNFILTERED")
    now = now + 120
    inCombat = false
    event("PLAYER_REGEN_ENABLED")
    assert(GabbaProcTrackerDB.counts[20007]["context_" .. context] == 1)
    assert(GabbaProcTrackerDB.stats[context][20007].seconds == 120)
end
local beforeLogout = GabbaProcTrackerDB.exportSequence
inCombat = true
area = "world"
event("PLAYER_REGEN_DISABLED")
now = now + 30
event("PLAYER_LOGOUT")
assert(GabbaProcTrackerDB.exportSequence == beforeLogout + 1)
local logoutHistory = GabbaProcTrackerDB.export.history
assert(logoutHistory[#logoutHistory].status == "complete")
assert(logoutHistory[#logoutHistory].duration == 30)
inCombat = false
area = "pvp"
event("COMBAT_LOG_EVENT_UNFILTERED")
assert(GabbaProcTrackerDB.counts[20007].context_world == 1)
SlashCmdList.GABBAPROCTRACKER("reset")
assert(GabbaProcTrackerDB.counts[20007])
SlashCmdList.GABBAPROCTRACKER("reset confirm")
assert(next(GabbaProcTrackerDB.counts) == nil)
print("PASS: addon lifecycle, UI views, combat integration, custom commands, PvP exclusion, reset confirmation")

-- Exercise actual equipment detection, including offhand and ranged slots.
local equipment = {}
GetInventoryItemID = function(_, slot) return equipment[slot] end
GetInventoryItemLink = function(_, slot) return equipment[slot] and ("item:" .. equipment[slot] .. ":0:0") end
local function proc(id, subevent, timestamp, dest, source)
    CombatLogGetCurrentEventInfo = function()
        return timestamp or now, subevent, false, source or "me", nil, nil, nil, dest or "me", nil, nil, nil, id, "Generic proc name", 1, 2
    end
    event("COMBAT_LOG_EVENT_UNFILTERED")
end
for _, case in ipairs({
    { 1982, 18211, "SPELL_DAMAGE", 16 }, -- shared ID with Ebon Hand
    { 21190, 25906, "SPELL_AURA_APPLIED", 11 }, -- ring equipment and combat time
    { 11302, 10368, "SPELL_AURA_APPLIED", 13 },
    { 11810, 15595, "SPELL_AURA_APPLIED", 14 },
    { 14557, 18946, "SPELL_AURA_APPLIED", 13 },
    { 12798, 16928, "SPELL_AURA_APPLIED", 16, "enemy" },
    { 12791, 13318, "SPELL_AURA_APPLIED", 17, "enemy" },
    { 2243, 18803, "SPELL_AURA_APPLIED", 16 },
    { 17705, 21919, "SPELL_EXTRA_ATTACKS", 16 },
    { 871, 18797, "SPELL_EXTRA_ATTACKS", 17 },
    { 12590, 16551, "SPELL_AURA_APPLIED", 16 },
    { 12590, 16551, "SPELL_AURA_REFRESH", 17 },
    { 11684, 15494, "SPELL_EXTRA_ATTACKS", 16 },
    { 19170, 18211, "SPELL_DAMAGE", 16 },
    { 1168, 18817, "SPELL_DAMAGE", 17 },
    { 1168, 18818, "SPELL_DAMAGE", 17 },
    { 12592, 16602, "SPELL_SUMMON", 16 },
    { 2825, 29638, "SPELL_DAMAGE", 18 },
}) do
    SlashCmdList.GABBAPROCTRACKER("reset confirm")
    area, inCombat = "party", true
    equipment = { [case[4]] = case[1] }
    event("PLAYER_ENTERING_WORLD")
    proc(case[2], case[3], nil, case[5])
    proc(case[2], case[3], now, "me", "other")
    if case[2] == 18818 then
        proc(18818, "SPELL_DAMAGE", now, "target2")
        proc(18818, "SPELL_MISSED", now, "target3")
    elseif case[2] == 16602 then
        proc(16602, "SPELL_CAST_SUCCESS")
        proc(16596, "SPELL_DAMAGE", now, "enemy", "guardian")
        proc(16598, "SPELL_AURA_APPLIED", now, "me", "guardian")
    elseif case[2] == 18817 then
        proc(18817, "SPELL_HEAL")
    end
    now = now + 60
    inCombat = false
    event("PLAYER_REGEN_ENABLED")
    assert(GabbaProcTrackerDB.counts[case[2]].context_party == 1)
    assert(GabbaProcTrackerDB.stats.party[case[2]].seconds == 60)
    assert(GabbaProcTrackerDB.stats.party[case[2]].procs == 1)
    local export = ns.ExportCSV(ns.NewTracker(GabbaProcTrackerDB), "history", "Test", now)
    assert(export:find('"' .. case[2] .. '"', 1, true))
    equipment = {}
    event("PLAYER_EQUIPMENT_CHANGED", case[4])
    proc(case[2], case[3], now + 1)
    assert(GabbaProcTrackerDB.counts[case[2]].context_party == 1)
end
print("PASS: weapon/shield/ranged equipment, Felstriker both hands, Ironfoe counts once for two attacks, Shahram summon only, AoE grouping, exports")

local hunterClass, talentRank = "HUNTER", 1
UnitClass = function() return "Jaeger", hunterClass end
GetSpellInfo = function(id) if id == 19552 then return "Verbesserter Aspekt des Falken" end end
GetNumTalentTabs = function() return 3 end
GetNumTalents = function() return 1 end
GetTalentInfo = function(tab) return tab == 1 and "Verbesserter Aspekt des Falken" or "Anderes Talent", nil, 1, 1, talentRank end
equipment = {}
for rank = 1, 5 do
    talentRank = rank
    SlashCmdList.GABBAPROCTRACKER("reset confirm")
    area, inCombat = "none", true
    event("PLAYER_ENTERING_WORLD")
    proc(6150, "SPELL_AURA_APPLIED")
    proc(6150, "SPELL_AURA_REFRESH")
    proc(6150, "SPELL_AURA_REMOVED")
    proc(6150, "SPELL_AURA_APPLIED", now, "other")
    proc(6150, "SPELL_AURA_APPLIED", now, "me", "other")
    proc(3045, "SPELL_AURA_APPLIED") -- Rapid Fire is not Quick Shots
    now = now + 60
    inCombat = false
    event("PLAYER_REGEN_ENABLED")
    assert(GabbaProcTrackerDB.counts[6150].context_world == 2)
    assert(GabbaProcTrackerDB.stats.world[6150].seconds == 60)
    assert(GabbaProcTrackerDB.counts[3045] == nil)
end
talentRank = 0
event("CHARACTER_POINTS_CHANGED")
proc(6150, "SPELL_AURA_APPLIED")
assert(GabbaProcTrackerDB.counts[6150].context_world == 2)
inCombat = true
event("PLAYER_REGEN_DISABLED")
now = now + 30
talentRank = 1
event("CHARACTER_POINTS_CHANGED")
now = now + 30
inCombat = false
event("PLAYER_REGEN_ENABLED")
assert(GabbaProcTrackerDB.stats.world[6150].seconds == 90)
hunterClass = "WARRIOR"
event("SPELLS_CHANGED")
proc(6150, "SPELL_AURA_APPLIED")
assert(GabbaProcTrackerDB.counts[6150].context_world == 2)
print("PASS: Quick Shots all talent ranks, refresh, class/talent filtering, talent changes, Rapid Fire excluded")

local dotDB = {}
local dotTracker = ns.NewTracker(dotDB)
local function dot(eventType, id, dest, source, stamp)
    return dotTracker:Record(stamp or 1, eventType, source or "me", dest or "enemy", "me", id, "Effect", "raid", function() return true end)
end
assert(dot("SPELL_AURA_APPLIED", 13318))
assert(dot("SPELL_AURA_REFRESH", 13318))
assert(not dot("SPELL_PERIODIC_DAMAGE", 13318))
assert(not dot("SPELL_AURA_REMOVED", 13318))
assert(not dot("SPELL_AURA_APPLIED", 13318, "enemy", "someone-else"))
assert(not dot("SPELL_AURA_APPLIED", 13318, "me"))
assert(dot("SPELL_MISSED", 13318))
assert(dotDB.counts[13318].context_raid == 3)
assert(dot("SPELL_AURA_APPLIED", 16928))
assert(dot("SPELL_AURA_APPLIED_DOSE", 16928))
assert(dot("SPELL_AURA_REFRESH", 16928))
assert(not dot("SPELL_AURA_REMOVED_DOSE", 16928))
assert(not dot("SPELL_AURA_APPLIED_DOSE", 13318))
assert(dotDB.counts[16928].context_raid == 3)
assert(dot("SPELL_DAMAGE", 21992, "enemy1", "me", 10))
assert(not dot("SPELL_DAMAGE", 21992, "enemy2", "me", 10))
assert(not dot("SPELL_AURA_APPLIED", 21992, "enemy1", "me", 10))
assert(dot("SPELL_DAMAGE", 21992, "enemy1", "me", 11))
assert(dot("SPELL_DAMAGE", 21162))
assert(not dot("SPELL_PERIODIC_DAMAGE", 21162))
local total = 0
for id, effect in pairs(ns.effects) do
    total = total + 1
    assert(id > 0 and id < 100000, "Unexpected non-Era ID")
    assert(effect.name and (effect.aura or effect.event), "Missing trigger definition")
    assert(effect.item or effect.items or effect.enchant or effect.talentSpell or effect.talents, "Missing eligibility")
end
print("PASS: debuff ownership, DoT tick filtering, stack gains/loss, Thunderfury grouping, catalogue integrity (" .. total .. " effect groups)")

local talentNames = {
    [12281] = "Schwertspezialisierung", [13960] = "Schwertspezialisierung",
    [18094] = "Einbruch der Nacht", [17793] = "Verbesserter Schattenblitz",
}
local ranks = {}
GetSpellInfo = function(id) return talentNames[id] end
GetNumTalentTabs = function() return 1 end
GetNumTalents = function() return 3 end
GetTalentInfo = function(_, index)
    local name = ({ "Schwertspezialisierung", "Einbruch der Nacht", "Verbesserter Schattenblitz" })[index]
    return name, nil, 1, index, ranks[name] or 0
end
local weaponSubclass = 7
GetItemInfoInstant = function(id) return id, nil, nil, nil, nil, 2, weaponSubclass end
for _, class in ipairs({ "WARRIOR", "ROGUE" }) do
    hunterClass = class
    for rank = 1, 5 do
        for _, layout in ipairs({ {16, 7}, {17, 7}, {16, 8} }) do
            inCombat = false
            SlashCmdList.GABBAPROCTRACKER("reset confirm")
            ranks = { ["Schwertspezialisierung"] = rank }
            equipment = { [layout[1]] = 99999 }
            weaponSubclass = layout[2]
            area, inCombat = "raid", true
            event("PLAYER_ENTERING_WORLD")
            proc(16459, "SPELL_EXTRA_ATTACKS")
            proc(16459, "SWING_DAMAGE")
            proc(16459, "SPELL_CAST_SUCCESS")
            proc(16459, "SPELL_EXTRA_ATTACKS", now, "me", "other")
            now = now + 30
            weaponSubclass = 0 -- axe
            equipment = { [16] = 88888 }
            event("PLAYER_EQUIPMENT_CHANGED", 16)
            proc(16459, "SPELL_EXTRA_ATTACKS")
            now = now + 30
            inCombat = false
            event("PLAYER_REGEN_ENABLED")
            assert(GabbaProcTrackerDB.counts[16459].context_raid == 1)
            assert(GabbaProcTrackerDB.stats.raid[16459].seconds == 30)
            local csv = ns.ExportCSV(ns.NewTracker(GabbaProcTrackerDB), "counts", class, now)
            assert(csv:find('"16459"', 1, true))
        end
    end
end
-- Losing a talent during combat ends the eligible measurement interval.
equipment, weaponSubclass, inCombat = { [16] = 99999 }, 7, true
event("PLAYER_ENTERING_WORLD")
now = now + 10
ranks = {}
event("CHARACTER_POINTS_CHANGED")
proc(16459, "SPELL_EXTRA_ATTACKS")
now = now + 10
inCombat = false
event("PLAYER_REGEN_ENABLED")
assert(GabbaProcTrackerDB.counts[16459].context_raid == 1)
assert(GabbaProcTrackerDB.stats.raid[16459].seconds == 40)

hunterClass = "WARLOCK"
equipment = {}
for rank, debuff in ipairs({ 17794, 17798, 17797, 17799, 17800 }) do
    SlashCmdList.GABBAPROCTRACKER("reset confirm")
    ranks = { ["Einbruch der Nacht"] = math.min(rank, 2), ["Verbesserter Schattenblitz"] = rank }
    area, inCombat = "party", true
    event("PLAYER_ENTERING_WORLD")
    proc(17941, "SPELL_AURA_APPLIED")
    proc(17941, "SPELL_AURA_REFRESH")
    proc(17941, "SPELL_AURA_REMOVED")
    proc(686, "SPELL_CAST_SUCCESS")
    proc(debuff, "SPELL_AURA_APPLIED", now, "enemy")
    proc(debuff, "SPELL_AURA_REFRESH", now, "enemy")
    proc(debuff, "SPELL_AURA_REMOVED_DOSE", now, "enemy")
    proc(debuff, "SPELL_AURA_APPLIED_DOSE", now, "enemy")
    proc(debuff, "SPELL_AURA_APPLIED", now, "enemy", "other")
    proc(16459, "SPELL_EXTRA_ATTACKS")
    now = now + 60
    inCombat = false
    event("PLAYER_REGEN_ENABLED")
    assert(GabbaProcTrackerDB.counts[17941].context_party == 2)
    assert(GabbaProcTrackerDB.counts[17800].context_party == 2)
    assert(GabbaProcTrackerDB.counts[16459] == nil)
    assert(GabbaProcTrackerDB.counts[686] == nil)
    assert(GabbaProcTrackerDB.stats.party[17800].seconds == 60)
    assert(GabbaProcTrackerDB.stats.party[17941].seconds == 60)
    local csv = ns.ExportCSV(ns.NewTracker(GabbaProcTrackerDB), "history", "Warlock", now)
    assert(csv:find('"17800"', 1, true) and csv:find('"17941"', 1, true))
end
print("PASS: warrior/rogue Sword Specialization all ranks, hand/type changes, respec, warlock talents and all debuff aliases, charge consumption excluded")
