local _, ns = ...
ns.VERSION = "0.1.3"
ns.locale = GetLocale and GetLocale() or "enUS"
local english = {
    ["Export beim Gebietswechsel (Datei erst nach /reload oder Logout)"] = "Export on zone change (file written on /reload or logout)",
    ["Auto-Export aktualisiert den Snapshot. WoW schreibt die Datei erst bei /reload oder Logout."] = "Auto-export updates the snapshot. WoW writes the file only on /reload or logout.",
    ["Auto-Export beim Gebietswechsel: an."] = "Export on zone change: on.",
    ["Auto-Export beim Gebietswechsel: aus."] = "Export on zone change: off.",
    ["/gpt autoexport [on|off] – Snapshot beim Gebietswechsel aktualisieren"] = "/gpt autoexport [on|off] – update the snapshot on zone changes",
    ["Linksklick: Fenster oeffnen/schliessen"] = "Left-click: toggle window",
    ["Rechtsklick: Export speichern"] = "Right-click: save export",
    ["Ziehen: Position aendern"] = "Drag: move button",
    ["/gpt minimap – Minimap-Button ein-/ausblenden"] = "/gpt minimap – show/hide minimap button",

    ["Charakter"] = "Character",
    ["Seit"] = "Since",
    ["Segment"] = "Segment",
    ["Start"] = "Start",
    ["Status"] = "Status",
    ["Gruppe"] = "Group",
    ["Gebiet"] = "Zone",
    ["Zauber-ID"] = "Spell ID",
    ["Effekt"] = "Effect",
    ["Kampfsekunden"] = "Combat seconds",
    ["Procs gesamt"] = "Total procs",
    ["Procs im Kampf"] = "Combat procs",
    ["Procs/Kampfminute"] = "Procs/combat minute",
    ["laufend"] = "active",
    ["abgeschlossen"] = "complete",

    ["Open World"] = "Open World",
    ["Dungeon"] = "Dungeon",
    ["Raid"] = "Raid",
    ["%.1f s Kampfzeit; %d Procs"] = "%.1f s in combat; %d procs",
    ["Aktuell: "] = "Current: ",
    ["Nicht erfasst"] = "Not tracked",
    ["  |  Seit: "] = "  |  Since: ",
    ["Zeit / Effekt (Details: Maus)"] = "Time / effect (hover for details)",
    ["Gebietstyp"] = "Area type",
    ["Procs"] = "Procs",
    ["Kampfzeit"] = "Combat time",
    ["Effekt – Procs pro Kampfminute"] = "Effect – procs per combat minute",
    ["Effekt (Zauber-ID)"] = "Effect (spell ID)",
    ["\nKampfzeit mit gelerntem Talent, einschliesslich anderer Aspekte."] = "\nCombat time with the talent learned, including other aspects.",
    ["\nKampfzeit mit gelerntem Talent und mindestens einem Schwert."] = "\nCombat time with the talent learned and at least one sword equipped.",
    ["\nGesamte Kampfzeit mit gelerntem Talent; nur eigene Ausloesungen."] = "\nTotal combat time with the talent learned; only your own triggers.",
    ["\n%s: %d Procs / %.1f Kampfminuten"] = "\n%s: %d procs / %.1f combat minutes",
    ["Alle hinterlegten Effekte. Zaehlt bei passender Ausruestung bzw. gelerntem Talent."] = "All supported effects. Requires matching equipment or learned talent.",
    ["Letzte 300 abgeschlossene Kampfsegmente; Ausruestungswechsel teilt Segmente."] = "Last 300 completed combat segments; equipment changes split segments.",
    ["Procs/Kampfminute bei ausgeruestetem Effekt; keine Proc-Chance pro Treffer."] = "Procs per combat minute while equipped; not proc chance per hit.",
    ["Gesamt: %d Procs. Zaehlt auch bei geschlossenem Fenster."] = "Total: %d procs. Tracking continues with the window closed.",
    ["GabbaProcTracker – Procs pro Charakter"] = "GabbaProcTracker – procs per character",
    ["Noch keine Eintraege. Hilfe: /gpt help"] = "No entries yet. Help: /gpt help",
    ["Zaehler"] = "Counters",
    ["Procs / Minute"] = "Procs / minute",
    ["Verlauf"] = "History",
    ["Katalog"] = "Catalog",
    ["Zaehler dieses Charakters zurueckgesetzt."] = "Counters for this character reset.",
    ["Zum Loeschen aller Zaehler dieses Charakters: /gpt reset confirm"] = "To reset all counters for this character: /gpt reset confirm",
    ["/gpt add ZAUBER-ID buff|damage|heal|extra"] = "/gpt add SPELL-ID buff|damage|heal|extra",
    ["Dieser Effekt ist bereits eingebaut."] = "This effect is already built in.",
    ["Eigener Effekt "] = "Custom effect ",
    ["Effekt "] = "Effect ",
    [" hinzugefuegt."] = " added.",
    ["Eigener Effekt entfernt; bisherige Zaehler bleiben erhalten."] = "Custom effect removed; existing counters retained.",
    ["Bitte die ID eines eigenen Effekts angeben: /gpt remove ID"] = "Specify a custom effect ID: /gpt remove ID",
    ["/gpt – Fenster | /gpt reset confirm – Zaehler loeschen"] = "/gpt – window | /gpt reset confirm – reset counters",
    ["/gpt add ID buff|damage|heal|extra – eigenen Proc erfassen | /gpt remove ID"] = "/gpt add ID buff|damage|heal|extra – track a custom proc | /gpt remove ID",
    ["/gpt history – Verlauf | /gpt rates – Procs pro Kampfminute | /gpt counts – Zaehler"] = "/gpt history – history | /gpt rates – procs per combat minute | /gpt counts – counters",
    ["/gpt export – CSV-Zusammenfassung | /gpt export history – CSV-Verlauf"] = "/gpt export – save snapshot | /gpt csv [history] – copy CSV",
    ["/gpt list – Katalog aller eingebauten Effekte"] = "/gpt list – catalog of all supported effects",
    ["Gruppen: Open World, Dungeons, Raids. Schlachtfelder/Arenen werden nicht erfasst."] = "Groups: Open World, dungeons, raids. Battlegrounds/arenas are excluded.",
    ["Proc-Zaehler aktiv. Fenster: /gpt"] = "Proc tracker active. Window: /gpt",
    ["GabbaProcTracker – CSV-Export"] = "GabbaProcTracker – CSV export",
    ["Strg+A, Strg+C: kopieren. Als .csv speichern (UTF-8, Semikolon, Dezimalpunkt)."] = "Ctrl+A, Ctrl+C to copy. Save as .csv (UTF-8, semicolon, decimal point).",
    ["Export gespeichert. Jetzt /reload oder ausloggen, dann GabbaProcTracker.lua aus SavedVariables importieren."] = "Export saved. Use /reload or log out, then import GabbaProcTracker.lua from SavedVariables.",
    ["Ausserhalb eines Kampfsegments"] = "Outside a combat segment",
}
ns.L = setmetatable({}, { __index = function(_, key)
    if ns.locale == "deDE" then
        if key == "/gpt export – CSV-Zusammenfassung | /gpt export history – CSV-Verlauf" then
            return "/gpt export – Snapshot speichern | /gpt csv [history] – CSV kopieren"
        end
        return key
    end
    return english[key] or key
end })

-- WoW supplies spell/item names in the client's language. Do not use names
-- saved by an older client locale to label built-in effects.
function ns.EffectName(id, db)
    local effect = ns.effects[id]
    local spell
    if C_Spell and C_Spell.GetSpellInfo then
        local info = C_Spell.GetSpellInfo(id)
        spell = info and info.name
    elseif GetSpellInfo then spell = GetSpellInfo(id) end
    if not effect then
        return spell or (db.custom[id] or db.counts[id] or {}).name or ns.L["Eigener Effekt "] .. id
    end
    local itemNames = {}
    local getItem = C_Item and C_Item.GetItemInfo or GetItemInfo
    for _, item in ipairs(effect.items or (effect.item and { effect.item } or {})) do
        local name = getItem and getItem(item)
        if name then itemNames[#itemNames + 1] = name end
    end
    if #itemNames > 0 then
        return table.concat(itemNames, " / ") .. (spell and (": " .. spell) or "")
    end
    return spell or (ns.locale == "deDE" and effect.name) or ("Effect " .. id)
end
