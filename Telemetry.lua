local _, ns = ...
-- Numeric, bounded measurements only. Names, GUIDs and item links never leave this module.
local function call(fn, ...)
    if type(fn) ~= "function" then return nil end
    local ok, value = pcall(fn, ...)
    if ok and type(value) == "number" and value >= 0 and value == value then return value end
end
function ns.MeasureStats()
    local stats = {}
    for key, fn in pairs({ meleeCrit = GetCritChance, rangedCrit = GetRangedCritChance,
        meleeHitModifier = GetHitModifier, spellHitModifier = GetSpellHitModifier }) do
        stats[key] = call(fn)
    end
    if UnitAttackSpeed then
        local main, off = UnitAttackSpeed("player")
        stats.mainSpeed, stats.offSpeed = main, off
    end
    stats.rangedSpeed = call(UnitRangedDamage, "player")
    stats.haste = call(GetHaste)
    for school = 1, 7 do stats["spellCrit" .. school] = call(GetSpellCritChance, school) end
    for index, key in ipairs({ "strength", "agility", "stamina", "intellect", "spirit" }) do
        if UnitStat then local _, value = UnitStat("player", index); stats[key] = value end
    end
    local buffs = {}
    for index = 1, 40 do
        local id, stacks
        if C_UnitAuras and C_UnitAuras.GetAuraDataByIndex then
            local aura = C_UnitAuras.GetAuraDataByIndex("player", index, "HELPFUL")
            if not aura then break end
            id, stacks = aura.spellId, aura.applications
        elseif UnitBuff then
            local name, _, count, _, _, _, _, _, _, spell = UnitBuff("player", index)
            if not name then break end
            id, stacks = spell, count
        else break end
        if id then buffs[#buffs + 1] = { spellId = id, stacks = stacks or 0 } end
    end
    return stats, buffs
end
function ns.NewTelemetry(fightId)
    local stats, buffs = ns.MeasureStats()
    local classId = UnitClass and select(3, UnitClass("player")) or nil
    local equipment, talents = {}, {}
    for slot = 1, 18 do
        local id = GetInventoryItemID and GetInventoryItemID("player", slot)
        if id then
            local link = GetInventoryItemLink and GetInventoryItemLink("player", slot)
            equipment[#equipment + 1] = { slot = slot, itemId = id, enchantId = tonumber((link or ""):match("item:%d+:(%d+)")) or 0 }
        end
    end
    if GetNumTalentTabs and GetNumTalents and GetTalentInfo then
        for tab = 1, GetNumTalentTabs() do
            for index = 1, GetNumTalents(tab) do
                local _, _, _, _, rank = GetTalentInfo(tab, index)
                if rank and rank > 0 then talents[#talents + 1] = { tab = tab, index = index, rank = rank } end
            end
        end
    end
    return { version = 1, fightId = fightId, classId = classId, level = call(UnitLevel, "player"), equipment = equipment, talents = talents,
        samples = { { atMs = 0, stats = stats, buffs = buffs } }, attacks = {}, procTimes = {}, targets = 0, truncated = false, samplesTruncated = false }
end
function ns.SampleTelemetry(tracker, now)
    local s = tracker.session
    if not s or not s.telemetry then return end
    local t = s.telemetry
    local at = math.floor(math.max(0, now - s.start) * 1000)
    if #t.samples >= 32 or at - t.samples[#t.samples].atMs < 1000 then t.samplesTruncated = true; return end
    local stats, buffs = ns.MeasureStats()
    t.samples[#t.samples + 1] = { atMs = at, stats = stats, buffs = buffs }
end
function ns.ObserveCombat(tracker, player, ...)
    local s = tracker.session
    if not s or not s.telemetry then return end
    local event, source, dest = select(2, ...), select(4, ...), select(8, ...)
    if source ~= player then return end
    local t = s.telemetry
    local kind, spell, hand, outcome = nil, 0, "none", "hit"
    if event == "SWING_DAMAGE" then
        kind, hand = "swing", select(21, ...) and "off" or "main"
        if select(18, ...) then outcome = "crit" elseif select(19, ...) then outcome = "glancing" end
    elseif event == "SWING_MISSED" then
        kind, hand, outcome = "swing", select(13, ...) and "off" or "main", select(12, ...)
    elseif event == "SPELL_DAMAGE" or event == "RANGE_DAMAGE" or event == "SPELL_PERIODIC_DAMAGE" then
        kind = event == "RANGE_DAMAGE" and "ranged" or event == "SPELL_PERIODIC_DAMAGE" and "periodic" or "spell"
        spell = select(12, ...)
        if select(21, ...) then outcome = "crit" end
    elseif event == "SPELL_MISSED" or event == "RANGE_MISSED" or event == "SPELL_PERIODIC_MISSED" then
        kind = event == "RANGE_MISSED" and "ranged" or event == "SPELL_PERIODIC_MISSED" and "periodic" or "spell"
        spell, outcome = select(12, ...), select(15, ...)
    elseif event == "SPELL_CAST_SUCCESS" then kind, spell, outcome = "cast", select(12, ...), "cast"
    else return end
    local allowed = { hit=true, crit=true, glancing=true, cast=true, MISS=true, DODGE=true, PARRY=true, BLOCK=true, RESIST=true, IMMUNE=true, EVADE=true, DEFLECT=true, ABSORB=true, REFLECT=true }
    if not allowed[outcome] then outcome = "other" end
    tracker.telemetryTargets = tracker.telemetryTargets or {}
    if kind ~= "cast" and dest and not tracker.telemetryTargets[dest] then
        if t.targets < 500 then tracker.telemetryTargets[dest] = true; t.targets = t.targets + 1 else t.truncated = true end
    end
    for _, row in ipairs(t.attacks) do
        if row.kind == kind and row.spellId == spell and row.hand == hand and row.outcome == outcome then row.count = row.count + 1; return end
    end
    if #t.attacks >= 256 then t.truncated = true; return end
    t.attacks[#t.attacks + 1] = { kind = kind, spellId = spell, hand = hand, outcome = outcome, count = 1 }
end
