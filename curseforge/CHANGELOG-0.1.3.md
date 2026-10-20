# GabbaProcTracker 0.1.3 — Raid-test measurements

- Record numeric character context per combat segment: class, level, equipped item/enchantment IDs, talent ranks, available stats and sampled buffs.
- Record own attack outcomes (including crits, misses, dodge/parry and off-hand swings), spell cast counts and relative proc timestamps.
- Link equipment-split segments with a collection-local fight ID. Target GUIDs/names are never exported; only a bounded target count is retained.
- Bound detail recording and mark truncated timing/event data separately from incomplete stat/buff samples.
- New SavedVariables export schema 2 requires **GabbaProc Companion 0.1.3 or newer**. Older companion versions reject new snapshots instead of silently discarding detail fields.
- Existing counters and retained histories stay intact. `/reload` or logout writes the export to disk.

This is a pre-beta raid-test build. Automated Lua, transport and server tests cover the new format; real Classic Era raid validation is the next step. Observed damage events are not a universal denominator for proc chance. Sampled stats/buffs do not establish exact buff uptime, and API-unavailable stats remain absent.
