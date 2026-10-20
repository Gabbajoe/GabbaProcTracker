local addonName, ns = ...
local L = ns.L
local controller = CreateFrame("Frame")
local tracker, panel, db
local items, enchants = {}, {}
local learnedTalents = {}
local swordEquipped = false
local function TalentID(effect)
    local class = UnitClass and select(2, UnitClass("player"))
    if effect.talents then return effect.talents[class] end
    if effect.class and class ~= effect.class then return nil end
    return effect.talentSpell
end
local function ReadTalents()
    local previous = learnedTalents
    learnedTalents = {}
    local wanted = {}
    for _, effect in pairs(ns.effects) do
        local id = TalentID(effect)
        if id then
            local name
            if C_Spell and C_Spell.GetSpellInfo then
                local info = C_Spell.GetSpellInfo(id)
                name = info and info.name
            elseif GetSpellInfo then name = GetSpellInfo(id) end
            if name then wanted[name] = id end
        end
    end
    if GetNumTalentTabs and GetNumTalents and GetTalentInfo then
        for tab = 1, GetNumTalentTabs() do
            for index = 1, GetNumTalents(tab) do
                local name, _, _, _, rank = GetTalentInfo(tab, index)
                if wanted[name] and rank and rank > 0 then learnedTalents[wanted[name]] = true end
            end
        end
    end
    for id in pairs(previous) do if not learnedTalents[id] then return true end end
    for id in pairs(learnedTalents) do if not previous[id] then return true end end
    return false
end
local mode = "counts"
local labels = { world = L["Open World"], party = L["Dungeon"], raid = L["Raid"] }
local function Context()
    local inside, kind = IsInInstance()
    if not inside then return "world" end
    if kind == "party" or kind == "raid" then return kind end
end
local function Say(message)
    DEFAULT_CHAT_FRAME:AddMessage("|cff66ccffGabbaProcTracker:|r " .. message)
end

local function ReadEquipment()
    ReadTalents()
    items, enchants = {}, {}
    swordEquipped = false
    local links = {}
    for slot = 1, 18 do
        local id = GetInventoryItemID("player", slot)
        if id then items[id] = true end
        local link = GetInventoryItemLink("player", slot)
        links[slot] = link or tostring(id or "")
        if slot == 16 or slot == 17 then
            local getInfo = C_Item and C_Item.GetItemInfoInstant or GetItemInfoInstant
            if id and getInfo then
                local _, _, _, _, _, classID, subClassID = getInfo(id)
                if classID == 2 and (subClassID == 7 or subClassID == 8) then swordEquipped = true end
            end
            local enchant = link and tonumber(link:match("item:%d+:(%d+)"))
            if enchant then enchants[enchant] = true end
        end
    end
    return table.concat(links, "|")
end

local function Equipped(effect)
    if effect.class and (not UnitClass or select(2, UnitClass("player")) ~= effect.class) then return false end
    if effect.talentSpell or effect.talents then
        local id = TalentID(effect)
        if not id or not learnedTalents[id] then return false end
    end
    if effect.sword and not swordEquipped then return false end
    if effect.items then
        for _, item in ipairs(effect.items) do if items[item] then return true end end
        return false
    end
    if effect.item then return items[effect.item] == true end
    if effect.enchant then return enchants[effect.enchant] == true end
    return true -- Explicitly configured custom spells.
end

local function BeginSegment(forceCombat)
    tracker:Finish(GetTime())
    local context = Context()
    if context and (forceCombat or UnitAffectingCombat("player")) then
        tracker:Begin(context, GetRealZoneText() or "?", GetTime(), date("%d.%m. %H:%M:%S"), Equipped)
    end
end

local function Rows()
    local rows, seen = {}, {}
    if mode == "history" then
        for index = #db.history, 1, -1 do
            local segment = db.history[index]
            local ids = {}
            for id in pairs(segment.effects) do ids[id] = true end
            for id in pairs(segment.counts) do ids[id] = true end
            local sorted = {}
            for id in pairs(ids) do sorted[#sorted + 1] = id end
            table.sort(sorted)
            for _, id in ipairs(sorted) do
                local effect = db.counts[id] or db.custom[id] or ns.effects[id] or {}
                local name = ns.EffectName(id, db)
                local count = segment.counts[id] or 0
                rows[#rows + 1] = {
                    id = id, name = segment.stamp .. "  " .. name,
                    detail = (labels[segment.context] or "?") .. " – " .. L[segment.zone] .. "\n" .. name .. " (" .. id .. ")\n" .. string.format(L["%.1f s Kampfzeit; %d Procs"], segment.duration, count),
                    values = { labels[segment.context] or "?", count, string.format("%.0fs", segment.duration) },
                }
            end
        end
        return rows
    end
    for id, effect in pairs(ns.effects) do
        if mode == "catalog" or Equipped(effect) or db.counts[id] then
            rows[#rows + 1] = { id = id, name = effect.name }
            seen[id] = true
        end
    end
    for id, effect in pairs(db.custom) do
        if not seen[id] then
            rows[#rows + 1] = { id = id, name = effect.name }
            seen[id] = true
        end
    end
    for id, row in pairs(db.counts) do
        if not seen[id] then rows[#rows + 1] = { id = id, name = row.name } end
    end
    table.sort(rows, function(a, b) return a.id < b.id end)
    return rows
end

local function Refresh()
    if not panel or not panel:IsShown() then return end
    panel.autoExport:SetChecked(db.autoExportOnZone == true)
    panel.status:SetText(L["Aktuell: "] .. (labels[Context()] or L["Nicht erfasst"]) .. L["  |  Seit: "] .. db.since)
    local headers = mode == "history" and { L["Zeit / Effekt (Details: Maus)"], L["Gebietstyp"], L["Procs"], L["Kampfzeit"] } or { mode == "rates" and L["Effekt – Procs pro Kampfminute"] or L["Effekt (Zauber-ID)"], L["Open World"], L["Dungeon"], L["Raid"] }
    for index, header in ipairs(headers) do panel.headers[index]:SetText(header) end
    local rows = Rows()
    local totalWorld, totalInstance = 0, 0
    for index, entry in ipairs(rows) do
        local line = panel.rows[index]
        if not line then
            line = CreateFrame("Frame", nil, panel.content)
            line:SetSize(530, 24)
            line:SetPoint("TOPLEFT", 0, -(index - 1) * 24)
            line.label = line:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
            line.label:SetPoint("LEFT", 4, 0)
            line.label:SetWidth(290)
            line.label:SetJustifyH("LEFT")
            line.values = {}
            for column = 1, 3 do
                local text = line:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
                text:SetPoint("RIGHT", line, "LEFT", 370 + (column - 1) * 75, 0)
                line.values[column] = text
            end
            panel.rows[index] = line
            line:EnableMouse(true)
            line:SetScript("OnEnter", function(self)
                GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
                GameTooltip:SetText(self.detail or "")
                GameTooltip:Show()
            end)
            line:SetScript("OnLeave", function() GameTooltip:Hide() end)
        end
        local count = db.counts[entry.id] or {}
        local world, instance = count.world or 0, count.instance or 0
        totalWorld, totalInstance = totalWorld + world, totalInstance + instance
        line.label:SetText(mode == "history" and entry.name or ns.EffectName(entry.id, db) .. " (" .. entry.id .. ")")
        line.detail = entry.detail or line.label:GetText()
        if entry.id == 6150 and mode ~= "history" then
            line.detail = line.detail .. L["\nKampfzeit mit gelerntem Talent, einschliesslich anderer Aspekte."]
        end
        if entry.id == 16459 and mode ~= "history" then
            line.detail = line.detail .. L["\nKampfzeit mit gelerntem Talent und mindestens einem Schwert."]
        end
        if (entry.id == 17941 or entry.id == 17800) and mode ~= "history" then
            line.detail = line.detail .. L["\nGesamte Kampfzeit mit gelerntem Talent; nur eigene Ausloesungen."]
        end
        for column, context in ipairs({ "world", "party", "raid" }) do
            if mode == "history" then
                line.values[column]:SetText(entry.values[column])
            elseif mode == "rates" then
                local rate, seconds, procs = tracker:Rate(entry.id, context, GetTime())
                line.values[column]:SetText(rate and string.format("%.2f", rate) or "–")
                line.detail = line.detail .. string.format(L["\n%s: %d Procs / %.1f Kampfminuten"], labels[context], procs, seconds / 60)
            else
                line.values[column]:SetText(count["context_" .. context] or 0)
            end
        end
        line:Show()
    end
    for index = #rows + 1, #panel.rows do panel.rows[index]:Hide() end
    panel.content:SetHeight(math.max(1, #rows * 24))
    panel.empty:SetShown(#rows == 0)
    panel.footer:SetText(mode == "catalog" and L["Alle hinterlegten Effekte. Zaehlt bei passender Ausruestung bzw. gelerntem Talent."] or mode == "history" and L["Letzte 300 abgeschlossene Kampfsegmente; Ausruestungswechsel teilt Segmente."] or mode == "rates" and L["Procs/Kampfminute bei ausgeruestetem Effekt; keine Proc-Chance pro Treffer."] or string.format(L["Gesamt: %d Procs. Zaehlt auch bei geschlossenem Fenster."], totalWorld + totalInstance))
end

local function CreatePanel()
    panel = CreateFrame("Frame", "GabbaProcTrackerFrame", UIParent, "BasicFrameTemplateWithInset")
    panel:SetSize(590, 380)
    panel:SetClampedToScreen(true)
    panel:SetMovable(true)
    panel:EnableMouse(true)
    panel:RegisterForDrag("LeftButton")
    panel:SetPoint("CENTER", UIParent, "CENTER", db.x or 0, db.y or 0)
    panel:SetScript("OnDragStart", panel.StartMoving)
    panel:SetScript("OnDragStop", function(self)
        self:StopMovingOrSizing()
        local x, y = self:GetCenter()
        local px, py = UIParent:GetCenter()
        db.x, db.y = x - px, y - py
    end)
    panel.TitleText:SetText(L["GabbaProcTracker – Procs pro Charakter"] .. " " .. ns.VERSION)
    panel.status = panel:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
    panel.status:SetPoint("TOPLEFT", 16, -35)
    local exportButton = CreateFrame("Button", "GabbaProcTrackerExportButton", panel, "UIPanelButtonTemplate")
    exportButton:SetSize(90, 22)
    exportButton:SetPoint("TOPRIGHT", -28, -28)
    exportButton:SetText("Export")
    exportButton:SetScript("OnClick", function()
        ns.SaveExport(tracker)
        Say(L["Export gespeichert. Jetzt /reload oder ausloggen, dann GabbaProcTracker.lua aus SavedVariables importieren."])
    end)
    panel.headers = {}
    for index, label in ipairs({ L["Effekt (Zauber-ID)"], L["Open World"], L["Dungeon"], L["Raid"] }) do
        local text = panel:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
        if index == 1 then text:SetPoint("TOPLEFT", 20, -60)
        else text:SetPoint("TOPRIGHT", panel, "TOPLEFT", 386 + (index - 2) * 75, -60) end
        text:SetText(label)
        panel.headers[index] = text
    end
    local scroll = CreateFrame("ScrollFrame", nil, panel, "UIPanelScrollFrameTemplate")
    scroll:SetPoint("TOPLEFT", 16, -82)
    scroll:SetPoint("BOTTOMRIGHT", -34, 84)
    panel.content = CreateFrame("Frame", nil, scroll)
    panel.content:SetSize(530, 1)
    scroll:SetScrollChild(panel.content)
    panel.rows = {}
    panel.empty = panel:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
    panel.empty:SetPoint("TOPLEFT", 20, -90)
    panel.empty:SetText(L["Noch keine Eintraege. Hilfe: /gpt help"])
    panel.footer = panel:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
    panel.footer:SetPoint("BOTTOMLEFT", 16, 62)
    panel.autoExport = CreateFrame("CheckButton", nil, panel, "UICheckButtonTemplate")
    panel.autoExport:SetSize(24, 24)
    panel.autoExport:SetPoint("BOTTOMLEFT", 14, 32)
    local autoLabel = panel.autoExport:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
    autoLabel:SetPoint("LEFT", panel.autoExport, "RIGHT", 2, 0)
    autoLabel:SetText(L["Export beim Gebietswechsel (Datei erst nach /reload oder Logout)"])
    panel.autoExport:SetScript("OnClick", function(self)
        db.autoExportOnZone = self:GetChecked() == true
        Say(L["Auto-Export aktualisiert den Snapshot. WoW schreibt die Datei erst bei /reload oder Logout."])
    end)
    for index, view in ipairs({ { "counts", L["Zaehler"] }, { "rates", L["Procs / Minute"] }, { "history", L["Verlauf"] }, { "catalog", L["Katalog"] } }) do
        local button = CreateFrame("Button", nil, panel, "UIPanelButtonTemplate")
        button:SetSize(132, 22)
        button:SetPoint("BOTTOMLEFT", 16 + (index - 1) * 140, 8)
        button:SetText(view[2])
        local selectedMode = view[1]
        button:SetScript("OnClick", function() mode = selectedMode; scroll:SetVerticalScroll(0); Refresh() end)
    end
    panel:SetScript("OnShow", Refresh)
    tinsert(UISpecialFrames, "GabbaProcTrackerFrame")
    panel:Hide()
end

local function Command(message)
    local command, rest = message:match("^%s*(%S*)%s*(.-)%s*$")
    command = command:lower()
    if command == "" then
        panel:SetShown(not panel:IsShown())
    elseif command == "export" then
        if rest ~= "" and rest ~= "history" and rest ~= "counts" then
            Say("/gpt export [counts|history]")
            return
        end
        ns.SaveExport(tracker)
        Say(L["Export gespeichert. Jetzt /reload oder ausloggen, dann GabbaProcTracker.lua aus SavedVariables importieren."])
    elseif command == "autoexport" then
        if rest ~= "" and rest ~= "on" and rest ~= "off" then
            Say("/gpt autoexport [on|off]")
            return
        end
        if rest == "on" then db.autoExportOnZone = true
        elseif rest == "off" then db.autoExportOnZone = false
        else db.autoExportOnZone = not db.autoExportOnZone end
        Refresh()
        Say(db.autoExportOnZone and L["Auto-Export beim Gebietswechsel: an."] or L["Auto-Export beim Gebietswechsel: aus."])
        if db.autoExportOnZone then
            Say(L["Auto-Export aktualisiert den Snapshot. WoW schreibt die Datei erst bei /reload oder Logout."])
        end
    elseif command == "minimap" then
        db.minimapHidden = not db.minimapHidden
        ns.RefreshMinimap()
    elseif command == "csv" then
        ns.ShowExport(tracker, rest == "history" and "history" or "counts")
    elseif command == "history" or command == "rates" or command == "counts" or command == "list" then
        mode = command == "list" and "catalog" or command
        panel:Show()
        Refresh()
    elseif command == "reset" then
        if rest == "confirm" then
            tracker:Reset()
            db.since = date("%d.%m.%Y %H:%M")
            BeginSegment()
            Refresh()
            Say(L["Zaehler dieses Charakters zurueckgesetzt."])
        else Say(L["Zum Loeschen aller Zaehler dieses Charakters: /gpt reset confirm"]) end
    elseif command == "add" then
        local id, mode = rest:match("^(%d+)%s+(%S+)$")
        id = tonumber(id)
        local events = { damage = "SPELL_DAMAGE", heal = "SPELL_HEAL", extra = "SPELL_EXTRA_ATTACKS" }
        if not id or id < 1 or (mode ~= "buff" and not events[mode]) then
            Say(L["/gpt add ZAUBER-ID buff|damage|heal|extra"])
            return
        end
        if ns.effects[id] or ns.aliases[id] then Say(L["Dieser Effekt ist bereits eingebaut."]); return end
        db.custom[id] = { name = L["Eigener Effekt "] .. id, aura = mode == "buff", event = events[mode] }
        BeginSegment()
        Say(L["Effekt "] .. id .. L[" hinzugefuegt."])
        Refresh()
    elseif command == "remove" then
        local id = tonumber(rest)
        if id and db.custom[id] then
            db.custom[id] = nil
            BeginSegment()
            Say(L["Eigener Effekt entfernt; bisherige Zaehler bleiben erhalten."])
            Refresh()
        else Say(L["Bitte die ID eines eigenen Effekts angeben: /gpt remove ID"]) end
    else
        Say(L["/gpt – Fenster | /gpt reset confirm – Zaehler loeschen"])
        Say(L["/gpt add ID buff|damage|heal|extra – eigenen Proc erfassen | /gpt remove ID"])
        Say(L["/gpt history – Verlauf | /gpt rates – Procs pro Kampfminute | /gpt counts – Zaehler"])
        Say(L["/gpt export – CSV-Zusammenfassung | /gpt export history – CSV-Verlauf"])
        Say(L["/gpt list – Katalog aller eingebauten Effekte"])
        Say(L["/gpt minimap – Minimap-Button ein-/ausblenden"])
        Say(L["/gpt autoexport [on|off] – Snapshot beim Gebietswechsel aktualisieren"])
        Say(L["Gruppen: Open World, Dungeons, Raids. Schlachtfelder/Arenen werden nicht erfasst."])
    end
end

controller:RegisterEvent("ADDON_LOADED")
controller:SetScript("OnEvent", function(_, event, ...)
    if event == "ADDON_LOADED" then
        if (...) ~= addonName then return end
        GabbaProcTrackerDB = GabbaProcTrackerDB or {}
        db = GabbaProcTrackerDB
        db.since = db.since or date("%d.%m.%Y %H:%M")
        tracker = ns.NewTracker(db)
        ns.EnsureIdentity(db)
        ReadEquipment()
        CreatePanel()
        ns.InitMinimap(db, function() Command("") end, function() Command("export") end)
        SLASH_GABBAPROCTRACKER1 = "/gpt"
        SLASH_GABBAPROCTRACKER2 = "/gabbaprocs"
        SlashCmdList.GABBAPROCTRACKER = Command
        controller:RegisterEvent("PLAYER_ENTERING_WORLD")
        controller:RegisterEvent("PLAYER_EQUIPMENT_CHANGED")
        controller:RegisterEvent("UNIT_INVENTORY_CHANGED")
        controller:RegisterEvent("COMBAT_LOG_EVENT_UNFILTERED")
        controller:RegisterEvent("PLAYER_REGEN_DISABLED")
        controller:RegisterEvent("PLAYER_REGEN_ENABLED")
        controller:RegisterEvent("PLAYER_LOGOUT")
        controller:RegisterEvent("ZONE_CHANGED_NEW_AREA")
        controller:RegisterEvent("CHARACTER_POINTS_CHANGED")
        controller:RegisterEvent("SPELLS_CHANGED")
        controller:RegisterEvent("GET_ITEM_INFO_RECEIVED")
        controller:UnregisterEvent("ADDON_LOADED")
        Say(L["Proc-Zaehler aktiv. Fenster: /gpt"])
    elseif event == "COMBAT_LOG_EVENT_UNFILTERED" then
        local context = Context()
        if not context then return end
        if UnitAffectingCombat("player") and (not tracker.session or tracker.session.context ~= context) then
            BeginSegment()
        end
        local timestamp, subevent, _, source, _, _, _, dest, _, _, _, id, name = CombatLogGetCurrentEventInfo()
        if tracker:Record(timestamp, subevent, source, dest, UnitGUID("player"), id, name, context, Equipped) then
            Refresh()
        end
    elseif event == "PLAYER_REGEN_DISABLED" then
        BeginSegment(true)
    elseif event == "PLAYER_REGEN_ENABLED" or event == "PLAYER_LOGOUT" then
        tracker:Finish(GetTime())
        -- WoW persists SavedVariables after PLAYER_LOGOUT (also /reload).
        -- Keep a fresh local snapshot; uploading remains a separate app opt-in.
        if event == "PLAYER_LOGOUT" then ns.SaveExport(tracker) end
        Refresh()
    elseif event == "GET_ITEM_INFO_RECEIVED" then
        Refresh()
    elseif event == "CHARACTER_POINTS_CHANGED" or event == "SPELLS_CHANGED" then
        if ReadTalents() then BeginSegment() end
        Refresh()
    elseif event ~= "UNIT_INVENTORY_CHANGED" or (...) == "player" then
        if event == "PLAYER_ENTERING_WORLD" then ns.RefreshMinimap() end
        local before = ReadEquipment()
        if event == "PLAYER_ENTERING_WORLD" or event == "ZONE_CHANGED_NEW_AREA" or ns.equipmentKey ~= before then
            BeginSegment()
        end
        ns.equipmentKey = before
        ns.MaybeZoneExport(tracker, event, ...)
        Refresh()
    end
end)

local elapsed = 0
controller:SetScript("OnUpdate", function(_, delta)
    elapsed = elapsed + delta
    if elapsed < 1 then return end
    elapsed = 0
    if tracker and mode == "rates" then Refresh() end
end)
