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
