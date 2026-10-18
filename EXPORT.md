# SavedVariables export schema 1 — GabbaProcTracker 0.1.0

Click Export or run `/gpt export`, then `/reload` or log out. Import the
character-specific `SavedVariables/GabbaProcTracker.lua` file. Read only the
`GabbaProcTrackerDB.export` table. The addon does not upload files or include a
web app. Parse the Lua table as data in the importer; do not execute uploaded Lua.

Keys and numeric types are identical for German and English clients.

| Field | Meaning |
| --- | --- |
| `schemaVersion` | Integer `1`; reject unsupported versions |
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

The addon retains only the latest export. To archive every exported snapshot,
the web app must save each imported file/snapshot. It can retain older segments
not present in the next rolling history window, but must not infer that every
segment was imported: gaps are possible. Totals cover the entire collection;
history covers only retained details. Older addon versions may have already
trimmed history without setting `historyTruncated`. An active segment which
falls out of the window before the next import cannot be finalized from that
later snapshot; keep it marked incomplete.

The UUID is not a login credential, cryptographic hash or anonymization feature.
Deleting the SavedVariables creates a new UUID; copying it copies the identity.
Names and realms are included, so users should choose which files to share.
