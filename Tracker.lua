local _, ns = ...

-- IDs checked against wowsims/classic sim/common/{enchant,item}_effects.go.
-- Count one canonical combat-log event per proc, never damage AND healing.
ns.effects = {
    [17941] = { name = "Schattentrance (Einbruch der Nacht)", aura = true, class = "WARLOCK", talentSpell = 18094, fixedName = true },
    [17800] = { name = "Schattenverwundbarkeit (Verb. Schattenblitz)", aura = true, targetAura = true, class = "WARLOCK", talentSpell = 17793, fixedName = true },
    [16459] = { name = "Schwertspezialisierung (Krieger/Schurke)", event = "SPELL_EXTRA_ATTACKS", talents = { WARRIOR = 12281, ROGUE = 13960 }, sword = true, fixedName = true },
    [18803] = { name = "Hand von Edward dem Seltsamen: Fokus", aura = true, item = 2243, fixedName = true },
    [21919] = { name = "Hauklinge: Doppelschlag", event = "SPELL_EXTRA_ATTACKS", item = 17705, fixedName = true },
    [18797] = { name = "Wirbelaxt: Zusatzangriff", event = "SPELL_EXTRA_ATTACKS", item = 871, fixedName = true },
    -- All Classic talent ranks trigger the same Quick Shots buff (hunter/aspects.go).
    [6150] = { name = "Schnelle Schuesse (Verb. Aspekt des Falken)", aura = true, class = "HUNTER", talentSpell = 19552, fixedName = true },
    [16602] = { name = "Schwarze Klinge von Shahram", event = "SPELL_SUMMON", item = 12592, fixedName = true },
    [29638] = { name = "Bogen der sengenden Pfeile", event = "SPELL_DAMAGE", item = 2825, fixedName = true },
    [16551] = { name = "Felstriker", aura = true, item = 12590, fixedName = true },
    [15494] = { name = "Ironfoe", event = "SPELL_EXTRA_ATTACKS", item = 11684, fixedName = true },
    [18211] = { name = "Ebenholzhand", event = "SPELL_DAMAGE", item = 19170, fixedName = true },
    [18817] = { name = "Schaedelflammenschild: Lebensentzug", event = "SPELL_DAMAGE", item = 1168, fixedName = true },
    [18818] = { name = "Schaedelflammenschild: Feuer", event = "SPELL_DAMAGE", item = 1168, aoe = true, fixedName = true },
    [20007] = { name = "Kreuzfahrer", aura = true, enchant = 1900 },
    [13897] = { name = "Feurige Waffe", event = "SPELL_DAMAGE", enchant = 803 },
    [6296] = { name = "Feuriger Schein", event = "SPELL_DAMAGE", enchant = 36, aoe = true },
    [20004] = { name = "Lebensdiebstahl", event = "SPELL_DAMAGE", enchant = 1898 },
    [15600] = { name = "Hand der Gerechtigkeit", event = "SPELL_EXTRA_ATTACKS", item = 11815 },
    [21970] = { name = "Mal der Auserwaehlten", aura = true, item = 17774 },
    [23688] = { name = "Dunkelmond: Blauer Drache", aura = true, item = 19288 },
    [23686] = { name = "Dunkelmond: Mahlstrom", event = "SPELL_DAMAGE", item = 19289 },
    [23689] = { name = "Dunkelmond: Heldentum", event = "SPELL_HEAL", item = 19287 },
    [27656] = { name = "Herz von Wyrmthalak", event = "SPELL_DAMAGE", item = 22321 },
}

-- Improved Shadow Bolt ranks 1-4 use separate debuff IDs; share one counter.
ns.aliases = { [17794] = 17800, [17797] = 17800, [17798] = 17800, [17799] = 17800 }

function ns.NewTracker(db)
    db.counts = db.counts or {}
    db.custom = db.custom or {}
    db.history = db.history or {}
    if not db.completedArchive then
        db.completedArchive = {}
        for _, entry in ipairs(db.history) do db.completedArchive[#db.completedArchive + 1] = entry end
        db.archiveTruncated = db.historyTruncated or false
    end
    db.stats = db.stats or {}
    -- Assign stable segment IDs to old histories once, then preserve them.
    db.nextSegmentId = db.nextSegmentId or 0
    for _, entry in ipairs(db.completedArchive) do
        db.nextSegmentId = math.max(db.nextSegmentId, entry.id or 0)
    end
    local function segmentId()
        db.nextSegmentId = db.nextSegmentId + 1
        return db.nextSegmentId
    end
    for _, entry in ipairs(db.completedArchive) do entry.id = entry.id or segmentId() end
    for _, entry in ipairs(db.history) do entry.id = entry.id or segmentId() end
    local tracker = { db = db, recent = {} }

    function tracker:Begin(context, zone, now, stamp, equipped, fightId)
        if self.session then self:Finish(now) end
        local effects = {}
        for id, effect in pairs(ns.effects) do
            if equipped(effect) then effects[id] = true end
        end
        for id in pairs(self.db.custom) do effects[id] = true end
        self.telemetryTargets = {}
        self.session = { id = segmentId(), startedAt = time and time() or nil, context = context, zone = zone, start = now, stamp = stamp, counts = {}, effects = effects }
        if ns.NewTelemetry then self.session.telemetry = ns.NewTelemetry(fightId or self.session.id) end
    end

    function tracker:Finish(now)
        local session = self.session
        if not session then return end
        self.session = nil
        session.duration = math.max(0, now - session.start)
        session.start = nil
        local stats = self.db.stats[session.context] or {}
        self.db.stats[session.context] = stats
        for id in pairs(session.effects) do
            local row = stats[id] or { seconds = 0, procs = 0 }
            stats[id] = row
            row.seconds = row.seconds + session.duration
            row.procs = row.procs + (session.counts[id] or 0)
        end
        table.insert(self.db.history, session)
        table.insert(self.db.completedArchive, session)
        if #self.db.history > 300 then table.remove(self.db.history, 1); self.db.historyTruncated = true end
    end

    function tracker:Rate(id, context, now)
        local row = (self.db.stats[context] or {})[id] or {}
        local seconds, procs = row.seconds or 0, row.procs or 0
        local session = self.session
        if session and session.context == context and session.effects[id] then
            seconds = seconds + math.max(0, now - session.start)
            procs = procs + (session.counts[id] or 0)
        end
        return seconds > 0 and procs * 60 / seconds or nil, seconds, procs
    end

    function tracker:Record(timestamp, event, source, destination, player, id, spellName, inside, equipped, now)
        if not player or not id then return false end
        id = ns.aliases[id] or id
        local effect = self.db.custom[id] or ns.effects[id]
        if not effect then return false end
        if effect.aura then
            if effect.targetAura then
                if source ~= player or not destination or destination == player then return false end
            else
                if destination ~= player then return false end
                if source ~= player and source ~= nil and source ~= "" then return false end
            end
            if event ~= "SPELL_AURA_APPLIED" and event ~= "SPELL_AURA_REFRESH"
                and not (effect.stacks and event == "SPELL_AURA_APPLIED_DOSE")
                and not (effect.targetAura and event == "SPELL_MISSED") then return false end
        else
            if source ~= player then return false end
            -- A resisted damage proc still triggered; count its miss event too.
            if event ~= effect.event and not (effect.event == "SPELL_DAMAGE" and event == "SPELL_MISSED") then
                return false
            end
        end
        if equipped and not equipped(effect) then return false end
        -- Area damage emits an event per target. Group the same log timestamp.
        if effect.aoe then
            local last = self.recent[id]
            if last and timestamp == last then return false end
            self.recent[id] = timestamp
        end
        local row = self.db.counts[id] or { world = 0, instance = 0 }
        self.db.counts[id] = row
        row.name = (effect.fixedName and effect.name) or spellName or effect.name or tostring(id)
        local bucket = (inside and inside ~= "world") and "instance" or "world"
        row[bucket] = (row[bucket] or 0) + 1
        local context = type(inside) == "string" and inside or (inside and "party" or "world")
        row["context_" .. context] = (row["context_" .. context] or 0) + 1
        if self.session and self.session.effects[id] then
            self.session.counts[id] = (self.session.counts[id] or 0) + 1
            local t = self.session.telemetry
            if t then
                if #t.procTimes < 1024 then
                    t.procTimes[#t.procTimes + 1] = { spellId = id, atMs = math.floor(math.max(0, (now or GetTime()) - self.session.start) * 1000) }
                else t.truncated = true end
            end
        else
            local segment = { id = segmentId(), startedAt = time and time() or nil, outsideCombat = true, context = context, zone = "Ausserhalb eines Kampfsegments", stamp = date and date("%d.%m. %H:%M:%S") or "", duration = 0, counts = { [id] = 1 }, effects = {} }
            table.insert(self.db.history, segment)
            table.insert(self.db.completedArchive, segment)
            if #self.db.history > 300 then table.remove(self.db.history, 1); self.db.historyTruncated = true end
        end
        return true
    end

    function tracker:Reset()
        if ns.PreserveCollection then ns.PreserveCollection(self) end
        self.db.collectionId = nil
        self.db.historyTruncated = false
        self.db.nextSegmentId = 0
        self.db.counts = {}
        self.db.stats = {}
        self.db.history = {}
        self.db.completedArchive = {}
        self.db.archiveTruncated = false
        self.session = nil
        self.recent = {}
    end
    return tracker
end
