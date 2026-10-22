# GabbaProcTracker 0.1.5

- Faster combat counters and exports with much less copying of completed fights.
- Detail archives now have a structural budget across counter resets. At capacity, a visible warning pauses new archived details; cumulative counters continue and existing data stays available.
- After exporting, reloading WoW and verifying a successful upload, `/gpt archive clear confirm` frees local detail history without deleting uploaded data or counters.
- Automatic zone exports wait until combat ends. Statistics sampling reserves a final sample for the end of long fights.
- Automated addon and packaging tests pass. Real raid performance still needs measurement in the WoW client.
