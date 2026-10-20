# SavedVariables export schema 1 — GabbaProcTracker 0.1.0

Click Export or run `/gpt export`, then `/reload` or log out. Import the
character-specific `SavedVariables/GabbaProcTracker.lua` file. Read only the
`GabbaProcTrackerDB.export` table. The addon does not upload files or include a
web app. Parse the Lua table as data in the importer; do not execute uploaded Lua.

Keys and numeric types are identical for German and English clients.

| Field | Meaning |
| --- | --- |
| `schemaVersion` | Integer `2` (since 0.1.3); reject unsupported versions |
| `addonVersion` | `0.1.0` |
| `characterId` | Persistent locally generated UUID, retained across counter resets |
| `collectionId` | UUID identifying one measurement series; changes after reset |
| `sequence` | Increasing export number for this character, retained across resets |
| `exportedAt` | Unix timestamp in seconds |
| `character` | `name`, `realm` (display metadata, not database keys) |
| `locale` | Client locale, such as `deDE` or `enUS` |
| `since` | Legacy human-readable collection start; not a machine timestamp |
| `groups` | `world`, `party`, `raid` |
| `totals` | Array of cumulative rows, including zero-proc exposure |
| `history` | Array of retained segments, plus a snapshot of active combat |
| `historyLimit` | `300` completed segments |
| `historyTruncated` | True when this version has discarded older segments |

Each totals row contains `spellId`, `effectName`, `group`, `procs`,
`combatProcs`, `combatSeconds`, and optional `procsPerMinute`.
`procs` includes triggers outside measured combat. `combatProcs` includes only
triggers during measured exposure. Missing rate means no measured combat time;
a zero rate with positive combat time is a valid observation. Names are display
metadata; always group effects by canonical numeric `spellId`.

Each history segment contains `id` (stable within its collection), `context`
(`world`/`party`/`raid`), `zone`, `stamp` (legacy display date), `duration`
(seconds), `counts` (spell-ID -> count), `effects` (eligible spell-ID -> true),
and `status` (`active` or `complete`). New segments also have `startedAt` (Unix
seconds). Migrated segments may lack this timestamp. `outsideCombat = true`
marks new zero-duration records outside measured combat. Include eligible
effects with no count as zero-proc observations. Do not compute a rate for
zero-duration records. WoW uptime `start` is deliberately excluded.

## Import and deduplication

Use `(characterId, collectionId)` as the collection key. For that collection,
replace cumulative totals only with a snapshot having a higher `sequence`.
An equal sequence is a duplicate; a lower sequence is an older snapshot. Never
sum cumulative snapshots. Distinct collections can be summed when appropriate.
Use `(characterId, collectionId, segment.id)` for segment upserts; a later
snapshot can replace an active segment with its completed version. Archived
snapshots can alternatively be stored by all three IDs including `sequence`.
An older collection imported later must not replace a newer collection.

Since 0.1.2, `export.archiveHistory` retains all available completed segments
plus the current segment; `archiveVersion = 1` identifies this archive extension.
`archiveTruncated` records known gaps inherited from older history. The legacy
`history` view remains limited to 300 completed segments plus the current one.
`GabbaProcTrackerDB.archivedExports` preserves collections before counter resets.
The companion imports those collections as well as the current export. Previously
trimmed segments cannot be recovered. Local archive size grows with play time.

The UUID is not a login credential, cryptographic hash or anonymization feature.
Deleting the SavedVariables creates a new UUID; copying it copies the identity.
Names and realms are included, so users should choose which files to share.

Since 0.1.1, logout and `/reload` automatically refresh the local snapshot after finalizing combat. Manual export remains available. This does not enable uploads; the companion needs explicit per-character consent.

## Combat detail recording (0.1.3)

`history` and `archiveHistory` entries can contain `telemetry.version = 1`. Historical entries without telemetry retain their meaning. Companion 0.1.3 reads SavedVariables schemas 1 and 2 and projects only the allowed numeric fields into upload schema 2.

Telemetry contains `fightId` (collection-local; equipment splits share it), optional `classId`/`level`, `equipment` (slot/itemId/enchantId), `talents` (tab/index/rank), `samples` (atMs/stats/buffs), aggregated `attacks` (kind/spellId/hand/outcome/count), `procTimes` (spellId/atMs) and unique target count. Timestamps are milliseconds since **segment start**, not fight start. No target GUIDs, player names, item links or talent names are included.

Limits: 32 stat/buff samples with at least one second between samples, 40 buffs per sample, 256 attack counter combinations, 1,024 proc timestamps and 500 counted targets per segment. `samplesTruncated` marks omitted context samples; `truncated` marks omitted combat details. Neither changes the original proc totals. Buff samples are snapshots, not exact aura uptime. Missing APIs produce absent values, not invented zeros. Hit modifiers are explicitly labeled modifiers, not an inferred hit probability against a target.

The local archive continues to grow. The companion's existing 64 MiB file and 256 KiB packet limits remain; large raid archives require monitoring during this pre-beta test.
