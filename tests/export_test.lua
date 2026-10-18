local ROOT = (arg[0]:match("^(.*[/\\])") or "") .. "../"
local function loadAddon(locale)
    GetLocale = function() return locale end
    local ns = {}
    for _, file in ipairs({ "Locale", "Tracker", "Catalog", "Export" }) do
        assert(loadfile(ROOT .. "" .. file .. ".lua"))("GabbaProcTracker", ns)
    end
    return ns
end
local now = 10
GetTime = function() return now end
UnitGUID = function() return "Player-1234-ABCDEF01" end
UnitName = function() return "Tester" end
GetRealmName = function() return "TestRealm" end
time = function() return 1792320000 end
local ns = loadAddon("deDE")
local db = { since = "2026-10-18" }
local tracker = ns.NewTracker(db)
ns.EnsureIdentity(db)
local identity = db.characterId
assert(identity:match('^%x%x%x%x%x%x%x%x%-%x%x%x%x%-4%x%x%x%-[89ab]%x%x%x%-%x%x%x%x%x%x%x%x%x%x%x%x$'))
assert(identity ~= db.collectionId)
tracker:Begin("world", "Elwynn", 10, "now", function(e) return e.enchant == 1900 end)
tracker:Record(12, "SPELL_AURA_APPLIED", "me", "me", "me", 20007, "Crusader", "world")
now = 40
local first = ns.SaveExport(tracker)
assert(first.schemaVersion == 1 and first.addonVersion == "0.1.0")
assert(first.characterId == identity and first.sequence == 1)
assert(first.totals[1].spellId == 20007 and first.totals[1].procsPerMinute == 2)
assert(first.totals[1].combatSeconds == 30 and first.totals[1].procs == 1)
assert(first.totals[2].procsPerMinute == nil and first.totals[2].combatSeconds == 0)
assert(first.history[1].status == "active" and first.history[1].start == nil)
assert(first.history[1].startedAt == time())
assert(tracker.session.start == 10 and #db.history == 0)
tracker:Record(45, "SPELL_AURA_REFRESH", "me", "me", "me", 20007, "Crusader", "world")
assert(first.history[1].counts[20007] == 1) -- deep snapshot, not live aliases
now = 70
tracker:Finish(now)
local second = ns.SaveExport(tracker)
assert(second.sequence == 2 and second.characterId == identity)
assert(second.collectionId == first.collectionId)
assert(second.history[1].id == first.history[1].id and second.history[1].status == "complete")
assert(second.totals[1].procs == 2 and second.totals[1].combatSeconds == 60)
assert(db.export == second and first.history[1].duration == 30)
local reloaded = ns.NewTracker(db)
ns.EnsureIdentity(db)
assert(db.characterId == identity and db.collectionId == first.collectionId)
reloaded:Reset()
assert(db.characterId == identity and db.export == second)
local third = ns.SaveExport(reloaded)
assert(third.collectionId ~= second.collectionId and third.characterId == identity)
assert(third.sequence == 3 and #third.totals == 0 and #third.history == 0)
for i = 1, 305 do
    reloaded:Begin("party", "Dungeon", i, "now", function(e) return e.enchant == 1900 end)
    reloaded:Finish(i + 1)
end
local fourth = ns.SaveExport(reloaded)
assert(fourth.historyTruncated and #fourth.history == 300)
assert(fourth.history[1].id == 6 and fourth.history[300].id == 305)
assert(fourth.totals[2].combatSeconds == 305 and fourth.totals[2].procs == 0)
local migrated = ns.NewTracker({ history = { { context = "world", effects = {}, counts = {}, duration = 0 } } })
local id = migrated.db.history[1].id
ns.NewTracker(migrated.db)
assert(migrated.db.history[1].id == id)
local other = {}
ns.EnsureIdentity(other)
assert(other.characterId ~= identity)
print("PASS: UUID persistence, independent characters, reset collection, snapshot isolation, live/complete segments, sequences, retention, migration")

for _, locale in ipairs({ "deDE", "enUS", "frFR" }) do
    local localized = loadAddon(locale)
    assert(localized.VERSION == "0.1.0")
    assert(localized.L.Zaehler == (locale == "deDE" and "Zaehler" or "Counters"))
    GetSpellInfo = function() return locale == "deDE" and "Heilige Staerke" or "Holy Strength" end
    assert(localized.EffectName(20007, db) == GetSpellInfo())
end
print("PASS: German/English localization, English fallback, names follow client language")
