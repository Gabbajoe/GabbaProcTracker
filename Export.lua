local _, ns = ...
local L = ns.L
local groups = { "world", "party", "raid" }
local names = { world = L["Open World"], party = L["Dungeon"], raid = L["Raid"] }
local function cell(value)
    local text = tostring(value or "")
    -- Keep imported text literal in spreadsheet applications.
    if text:match("^%s*[=+@%-]") then text = "'" .. text end
    return '"' .. text:gsub('"', '""') .. '"'
end
local function sortedKeys(set)
    local keys = {}
    for id in pairs(set) do keys[#keys + 1] = id end
    table.sort(keys)
    return keys
end
function ns.ExportCSV(tracker, kind, character, now)
    local db, lines = tracker.db, {}
    local function add(values)
        local cells = {}
        for i, value in ipairs(values) do cells[i] = cell(value) end
        lines[#lines + 1] = table.concat(cells, ";")
    end
    local function name(id)
        return (db.counts[id] or db.custom[id] or ns.effects[id] or {}).name or tostring(id)
    end
    if kind == "history" then
        add({ L["Charakter"], L["Seit"], L["Segment"], L["Start"], L["Status"], L["Gruppe"], L["Gebiet"], L["Zauber-ID"], L["Effekt"], L["Kampfsekunden"], L["Procs"], L["Procs/Kampfminute"] })
        local function segment(entry, index, active)
            local ids = {}
            for id in pairs(entry.effects) do ids[id] = true end
            for id in pairs(entry.counts) do ids[id] = true end
            local duration = active and math.max(0, now - entry.start) or entry.duration
            for _, id in ipairs(sortedKeys(ids)) do
                local procs = entry.counts[id] or 0
                add({ character, db.since or "", index, entry.stamp or "", active and L["laufend"] or L["abgeschlossen"], names[entry.context] or entry.context, entry.zone or "", id, name(id), string.format("%.3f", duration), procs, duration > 0 and string.format("%.6f", procs * 60 / duration) or "" })
            end
        end
        for index, entry in ipairs(db.history) do segment(entry, index, false) end
        if tracker.session then segment(tracker.session, #db.history + 1, true) end
    else
        add({ L["Charakter"], L["Seit"], L["Gruppe"], L["Zauber-ID"], L["Effekt"], L["Procs gesamt"], L["Procs im Kampf"], L["Kampfsekunden"], L["Procs/Kampfminute"] })
        local ids = {}
        for id in pairs(db.counts) do ids[id] = true end
        for id in pairs(db.custom) do ids[id] = true end
        for _, stats in pairs(db.stats) do for id in pairs(stats) do ids[id] = true end end
        if tracker.session then for id in pairs(tracker.session.effects) do ids[id] = true end end
        for _, id in ipairs(sortedKeys(ids)) do
            for _, context in ipairs(groups) do
                local rate, seconds, procs = tracker:Rate(id, context, now)
                add({ character, db.since or "", names[context], id, name(id), (db.counts[id] or {})["context_" .. context] or 0, procs, string.format("%.3f", seconds), rate and string.format("%.6f", rate) or "" })
            end
        end
    end
    return table.concat(lines, "\r\n") .. "\r\n"
end

local window, edit
function ns.ShowExport(tracker, kind)
    if not window then
        window = CreateFrame("Frame", "GabbaProcTrackerExportFrame", UIParent, "BasicFrameTemplateWithInset")
        window:SetSize(730, 450)
        window:SetPoint("CENTER")
        window:SetFrameStrata("DIALOG")
        window.TitleText:SetText(L["GabbaProcTracker – CSV-Export"])
        local hint = window:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
        hint:SetPoint("TOPLEFT", 16, -36)
        hint:SetText(L["Strg+A, Strg+C: kopieren. Als .csv speichern (UTF-8, Semikolon, Dezimalpunkt)."])
        local scroll = CreateFrame("ScrollFrame", nil, window, "UIPanelScrollFrameTemplate")
        scroll:SetPoint("TOPLEFT", 16, -60)
        scroll:SetPoint("BOTTOMRIGHT", -34, 20)
        edit = CreateFrame("EditBox", nil, scroll)
        edit:SetMultiLine(true)
        edit:SetAutoFocus(false)
        edit:SetFontObject(ChatFontNormal)
        edit:SetWidth(675)
        edit:SetMaxLetters(0)
        edit:SetScript("OnEscapePressed", function() window:Hide() end)
        edit:SetScript("OnTextChanged", function(self) scroll:UpdateScrollChildRect() end)
        scroll:SetScrollChild(edit)
        window:SetScript("OnHide", function() edit:ClearFocus() end)
        tinsert(UISpecialFrames, "GabbaProcTrackerExportFrame")
    end
    local character = (UnitName("player") or "?") .. "-" .. (GetRealmName() or "?")
    edit:SetText(ns.ExportCSV(tracker, kind, character, GetTime()))
    window:Show()
    edit:SetFocus()
    edit:HighlightText()
end

-- Persistent UUIDs are identifiers, not authentication tokens. Do not reseed
-- WoW's shared RNG. Mix in player identity/time to separate client sessions.
local uuidCounter = 0
local function uuid()
    uuidCounter = uuidCounter + 1
    local salt = tostring(UnitGUID and UnitGUID("player") or "") .. ":" .. tostring(time and time() or 0) .. ":" .. uuidCounter
    local hash = 0
    for i = 1, #salt do hash = (hash * 33 + salt:byte(i)) % 2147483647 end
    local bytes = {}
    for i = 1, 16 do
        hash = (hash * 48271) % 2147483647
        bytes[i] = (math.random(0, 255) + hash % 256) % 256
    end
    bytes[7] = 64 + bytes[7] % 16
    bytes[9] = 128 + bytes[9] % 64
    local parts = {}
    for i, value in ipairs(bytes) do
        parts[#parts + 1] = string.format("%02x", value)
        if i == 4 or i == 6 or i == 8 or i == 10 then parts[#parts + 1] = "-" end
    end
    return table.concat(parts)
end

function ns.EnsureIdentity(db)
    db.characterId = db.characterId or uuid()
    db.collectionId = db.collectionId or uuid()
end

local function copy(value)
    if type(value) ~= "table" then return value end
    local result = {}
    for k, v in pairs(value) do result[k] = copy(v) end
    return result
end

-- Stable keys and numeric values are independent of the UI language.
-- Replaces the latest snapshot; never adds cumulative totals to earlier ones.
function ns.SaveExport(tracker)
    local db, now = tracker.db, GetTime()
    ns.EnsureIdentity(db)
    db.exportSequence = (db.exportSequence or 0) + 1
    local snapshot = {
        schemaVersion = 2, addonVersion = ns.VERSION,
        characterId = db.characterId, collectionId = db.collectionId,
        sequence = db.exportSequence, exportedAt = time and time() or 0,
        locale = ns.locale, since = db.since,
        character = { name = UnitName("player"), realm = GetRealmName() },
        groups = { "world", "party", "raid" },
        historyLimit = 300, historyTruncated = db.historyTruncated or false,
        totals = {}, history = {}, archiveHistory = {},
        archiveVersion = 1, archiveTruncated = db.archiveTruncated or false,
    }
    local ids = {}
    for id in pairs(db.counts) do ids[id] = true end
    for id in pairs(db.custom) do ids[id] = true end
    for _, stats in pairs(db.stats) do for id in pairs(stats) do ids[id] = true end end
    if tracker.session then for id in pairs(tracker.session.effects) do ids[id] = true end end
    for _, id in ipairs(sortedKeys(ids)) do
        for _, context in ipairs(groups) do
            local rate, seconds, procs = tracker:Rate(id, context, now)
            snapshot.totals[#snapshot.totals + 1] = {
                spellId = id, effectName = ns.EffectName(id, db), group = context,
                procs = (db.counts[id] or {})["context_" .. context] or 0,
                combatProcs = procs, combatSeconds = seconds, procsPerMinute = rate,
            }
        end
    end
    local function addSegment(entry, active, destination)
        local segment = active and copy(entry) or entry
        segment.duration = active and math.max(0, now - entry.start) or entry.duration
        segment.start = nil -- GetTime is client uptime, never a portable timestamp.
        segment.status = active and "active" or "complete"
        destination[#destination + 1] = segment
    end
    for _, entry in ipairs(db.completedArchive or db.history) do addSegment(entry, false, snapshot.archiveHistory) end
    if tracker.session then
        addSegment(tracker.session, true, snapshot.archiveHistory)
    end
    db.export = snapshot
    return snapshot
end

-- Keep reset collections available for the companion, even if it was offline.
-- Archives do not recursively embed previous archives.
function ns.PreserveCollection(tracker)
    local db = tracker.db
    if not next(db.counts) and #(db.completedArchive or db.history) == 0 and not tracker.session then return end
    if #(db.archivedExports or {}) >= 100 then
        ns.ArchiveWarning()
        return false
    end
    local previous = db.export
    if tracker.session then tracker:Finish(GetTime()) end
    local snapshot = ns.SaveExport(tracker)
    db.archivedExports = db.archivedExports or {}
    db.archivedExports[#db.archivedExports + 1] = snapshot
    db.export = previous -- reset does not replace the last explicit export
end

-- A snapshot only changes SavedVariables in memory. WoW writes the file at
-- logout/reload; zone events cannot force a disk flush or a companion upload.
function ns.MaybeZoneExport(tracker, event, initialLogin, reloading)
    if not tracker.db.autoExportOnZone then return false end
    if event ~= "ZONE_CHANGED_NEW_AREA" and event ~= "PLAYER_ENTERING_WORLD" then return false end
    if event == "PLAYER_ENTERING_WORLD" and (initialLogin or reloading) then return false end
    if tracker.session then tracker.pendingExport = true; return false end
    ns.SaveExport(tracker)
    return true
end
