local ns = {}
local now = 10
GetTime = function() return now end
UnitClass = function() return "Warrior", "WARRIOR", 1 end
UnitLevel = function() return 60 end
UnitAttackSpeed = function() return 2.6, 1.8 end
GetCritChance = function() return 24 end
GetInventoryItemID = function(_, slot) if slot == 16 then return 12590 end end
GetInventoryItemLink = function() return "item:12590:1900:PRIVATE_NAME" end
assert(loadfile("Telemetry.lua"))("test", ns)
assert(loadfile("Tracker.lua"))("test", ns)
local t=ns.NewTracker({})
t:Begin("raid","PrivateZone",10,"",function()return true end,42)
assert(t.session.telemetry.fightId==42)
assert(t.session.telemetry.samples[1].stats.meleeCrit==24)
assert(t.session.telemetry.equipment[1].enchantId==1900)
ns.ObserveCombat(t,"me",0,"SWING_DAMAGE",false,"other","secret",0,0,"target", "name",0,0,12,0,1,0,0,0,true,false,false,false)
assert(#t.session.telemetry.attacks==0)
ns.ObserveCombat(t,"me",0,"SWING_DAMAGE",false,"me","secret",0,0,"target", "name",0,0,12,0,1,0,0,0,true,false,false,true)
assert(t.session.telemetry.attacks[1].outcome=="crit" and t.session.telemetry.attacks[1].hand=="off")
ns.ObserveCombat(t,"me",0,"SWING_MISSED",false,"me","secret",0,0,"target", "name",0,0,"DODGE",false)
assert(t.session.telemetry.attacks[2].outcome=="DODGE")
now=12
t:Record(999,"SPELL_AURA_APPLIED","me","me","me",20007,"", "raid",function()return true end,now)
assert(t.session.telemetry.procTimes[1].atMs==2000)
assert(t.session.telemetry.targets==1)
ns.SampleTelemetry(t,12)
assert(#t.session.telemetry.samples==2)
ns.SampleTelemetry(t,12.1)
assert(t.session.telemetry.samplesTruncated and not t.session.telemetry.truncated)
t:Finish(13)
assert(t.db.history[1].telemetry.procTimes[1].atMs==2000)
print("PASS: numeric character context, own attacks, off-hand crit/miss, relative proc times, target count and truncation")
