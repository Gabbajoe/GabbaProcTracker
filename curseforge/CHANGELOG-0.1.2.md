# GabbaProcTracker 0.1.2

- Preserve completed combat segments beyond the 300-entry history view for companion uploads.
- Preserve previous collections when resetting counters; character UUIDs remain unchanged.
- Add optional export snapshots on zone changes: `/gpt autoexport on` (off by default).
- WoW writes SavedVariables on `/reload` or logout. Zone changes alone do not write files.
- Compatible with GabbaProc Companion 0.1.2 archive uploads. Uploading remains opt-in.

Existing history already removed by older versions cannot be recovered. The local
archive grows as you play. Automated logic and packaging tests pass; further
real-client gameplay and large-archive validation remain pending.
