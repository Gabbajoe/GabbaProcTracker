# Archive development

Unreleased work on `feature/durable-exports`:

- Optional automatic export on zone transitions, disabled by default. Enable
  with the window checkbox or `/gpt autoexport on`; disable with `off`.
- Completed fights remain in `completedArchive` beyond the UI's 300-row history.
  Export snapshots add `archiveHistory`, `archiveVersion` and `archiveTruncated`
  while keeping legacy schema 1 fields for existing companions.
- Reset preserves the completed collection in `archivedExports` before starting
  a new collection. Existing character identity remains stable.
- Migration preserves any existing history-loss flag. Previously discarded
  fights cannot be recovered.

The current public companion does not upload these archive fields or old reset
collections. Bounded upload batches and receipt handling are still required.
The local archive is not automatically pruned: long-running memory and file-size
behavior must be assessed before release. Export copies the archive into a stable
snapshot, so large archives also increase snapshot work and SavedVariables size.

Zone changes cannot force a SavedVariables disk write: `/reload` or logout is
still required before the companion can read the updated export.

Validation: the Lua suite passes for DE/EN, including opt-in zone handling,
305 retained fights, archived reset collections, snapshot isolation and legacy
history migration. Real-client performance and gameplay checks remain pending.
