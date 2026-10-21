# GabbaProcTracker 0.1.4 — Window behavior and clearer guidance

- Match the Gabba window layer: MEDIUM strata, raised on click. Escape continues to close the tracker through WoW’s normal window handling.
- Rewrite the addon description around tracking, persistent archives and optional community uploads; explain the existing auto-export checkbox first.
- No change to stored measurements or export schema.

# GabbaProcTracker 0.1.3 — Raid-test measurements

- Record numeric character context per combat segment: class, level, equipped item/enchantment IDs, talent ranks, available stats and sampled buffs.
- Record own attack outcomes (including crits, misses, dodge/parry and off-hand swings), spell cast counts and relative proc timestamps.
- Link equipment-split segments with a collection-local fight ID. Target GUIDs/names are never exported; only a bounded target count is retained.
- Bound detail recording and mark truncated timing/event data separately from incomplete stat/buff samples.
- New SavedVariables export schema 2 requires **GabbaProc Companion 0.1.3 or newer**. Older companion versions reject new snapshots instead of silently discarding detail fields.
- Existing counters and retained histories stay intact. `/reload` or logout writes the export to disk.

This is a pre-beta raid-test build. Automated Lua, transport and server tests cover the new format; real Classic Era raid validation is the next step. Observed damage events are not a universal denominator for proc chance. Sampled stats/buffs do not establish exact buff uptime, and API-unavailable stats remain absent.

# GabbaProcTracker 0.1.2

- Preserve completed combat segments beyond the 300-entry history view for companion uploads.
- Preserve previous collections when resetting counters; character UUIDs remain unchanged.
- Add optional export snapshots on zone changes: `/gpt autoexport on` (off by default).
- WoW writes SavedVariables on `/reload` or logout. Zone changes alone do not write files.
- Compatible with GabbaProc Companion 0.1.2 archive uploads. Uploading remains opt-in.

Existing history already removed by older versions cannot be recovered. The local
archive grows as you play. Automated logic and packaging tests pass; further
real-client gameplay and large-archive validation remain pending.

# GabbaProcTracker 0.1.1

- Automatically save a fresh local export on logout or /reload, after closing the combat segment.
- Companion uploads remain a separate explicit opt-in; the addon never connects to a website.

# GabbaProcTracker 0.1.0

Initial public version for WoW Classic Era / Hardcore (interface 11509).

- Track 93 effect groups covering weapons, shields, enchants, trinkets and talents.
- Separate Open World, dungeon and raid totals, combat-minute rates and history.
- German and English interface with localized client spell/item names.
- Round minimap icon: left-click to toggle, right-click to export, drag to move.
- SavedVariables snapshots with persistent character UUIDs, collection IDs and
  export sequences; optional CSV export.
- Automated Lua tests, deterministic release ZIPs and SHA256 checksums.

Known limits: 300 completed history segments; no per-hit proc probability;
shared spell IDs are grouped; real-client visual/gameplay checks still pending.
