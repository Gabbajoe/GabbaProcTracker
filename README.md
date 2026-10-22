<p align="center">
  <img src="curseforge/logo.png" alt="GabbaProcTracker — turquoise proc lightning and golden statistics bars" width="200">
</p>

<h1 align="center">GabbaProcTracker</h1>

<p align="center">
  <strong>Count the sparks. Compare your procs.</strong><br>
  Weapon, trinket and talent procs across Open World, dungeons and raids. ⚡
</p>

<p align="center">
  <a href="https://github.com/Gabbajoe/GabbaProcTracker/actions/workflows/ci.yml"><img src="https://github.com/Gabbajoe/GabbaProcTracker/actions/workflows/ci.yml/badge.svg?branch=main" alt="Tests and package build"></a>
  <a href="https://github.com/Gabbajoe/GabbaProcTracker/releases"><img src="https://img.shields.io/github/v/release/Gabbajoe/GabbaProcTracker?style=flat-square&amp;color=22d3ee&amp;label=Release" alt="Latest published release"></a>
  <a href="https://github.com/Gabbajoe/GabbaProcTracker/releases"><img src="https://img.shields.io/github/downloads/Gabbajoe/GabbaProcTracker/total?style=flat-square&amp;color=fbbf24&amp;label=GitHub%20downloads" alt="GitHub release downloads"></a>
  <a href="LICENSE"><img src="https://img.shields.io/badge/License-MIT-34d399?style=flat-square" alt="MIT license"></a>
</p>

<p align="center">
  <img src="https://img.shields.io/badge/WoW-Classic_Era_%26_Hardcore-22d3ee?style=flat-square" alt="WoW Classic Era and Hardcore">
  <img src="https://img.shields.io/badge/Interface-11509-38bdf8?style=flat-square" alt="Interface 11509">
  <img src="https://img.shields.io/badge/Languages-English_%2F_Deutsch-fbbf24?style=flat-square" alt="English and German interface">
  <img src="https://img.shields.io/badge/CurseForge--Project-1752634-f16436?style=flat-square" alt="CurseForge project 1752634">
</p>

<p align="center">
  <a href="https://github.com/Gabbajoe/GabbaProcTracker/releases"><strong>📦 Downloads</strong></a> ·
  <a href="https://github.com/Gabbajoe/GabbaProcTracker/issues"><strong>💬 Ideas &amp; issues</strong></a> ·
  <a href="CHANGELOG.md"><strong>📝 Changelog</strong></a> ·
  <a href="RELEASING.md"><strong>🛠️ Development</strong></a> ·
  <a href="README.de.md"><strong>🇩🇪 Deutsch</strong></a>
</p>

---

**GabbaProcTracker** tracks your supported weapon, shield, enchantment, trinket
and talent procs in **WoW Classic Era / Hardcore**. Compare counts and combat-minute
rates across **Open World, dungeons and raids**, then export your observations.

A standalone addon with **93 built-in effect groups**, its own window and a round
minimap button. **No additional addons or external libraries required.**
The interface uses German on a `deDE` client and English otherwise; spell and
item names come from your WoW client.

## ✨ Features

| Feature | What you get |
| --- | --- |
| ⚔️ **Proc counters** | Separate totals for Open World, dungeons and raids |
| ⏱️ **Combat rates** | Procs per combat minute while the equipment or talent is eligible |
| 📜 **History** | Last 300 completed combat segments with zone, duration and counts, including zero-proc fights |
| 📚 **Catalog** | 93 supported effect groups and custom proc spell IDs |
| 🧭 **Minimap** | Round icon, draggable position, window toggle and quick export |
| 💾 **Saved data** | Per-character persistence, a stable UUID and separate measurement collections |
| 📤 **Export** | SavedVariables snapshots for external analysis, plus copyable CSV |

Tracking continues with the window closed. Cumulative totals and combat time
remain available after older segments leave the history window.

## 📦 Installation

1. Download the ZIP from [Releases](https://github.com/Gabbajoe/GabbaProcTracker/releases).
2. Extract the `GabbaProcTracker` folder into `_classic_era_/Interface/AddOns/`.
3. Restart WoW, enable the addon at character selection and type `/gpt`.

Version **0.1.0** was uploaded to CurseForge project **1752634**, file **9243572**.
Upload succeeded; public availability/moderation approval has not been verified.

## 🧭 Controls

| Action | Result |
| --- | --- |
| Minimap **left-click** | Open or close the tracker |
| Minimap **right-click** | Save an export snapshot |
| **Drag** the minimap icon | Move it; position is saved per character |
| `/gpt` or `/gabbaprocs` | Toggle the window |
| `/gpt minimap` | Hide or restore the minimap button |
| `/gpt counts` · `/gpt rates` · `/gpt history` | Open counters, combat rates or history |
| `/gpt list` | Show the built-in catalog |
| `/gpt export` | Save totals and history together to SavedVariables |
| `/gpt autoexport [on\|off]` | Toggle snapshots on zone changes (off by default) |
| `/gpt csv` · `/gpt csv history` | Open copyable CSV totals or history |
| `/gpt reset confirm` | Reset measurements; keep custom effects and character UUID |

Hover over a row for details. Equipment, zone or talent changes can split combat
segments. A running segment appears in history when completed, and is included
as an active snapshot when exporting.

## ⚡ Supported procs

| Source | Examples |
| --- | --- |
| **Weapons** | Felstriker, Ironfoe, Thrash Blade, Flurry Axe, Ebon Hand, Hand of Edward the Odd, Blackblade of Shahram |
| **Shields & ranged** | Skullflame Shield (separate fire and life-drain counters), Bow of Searing Arrows |
| **Enchantments** | Crusader, Fiery Weapon, Fiery Blaze, Lifestealing |
| **Trinkets** | Hand of Justice, Mark of the Chosen, Darkmoon Cards, Heart of Wyrmthalak |
| **Hunter talents** | Improved Aspect of the Hawk / Quick Shots |
| **Warrior & rogue talents** | Sword Specialization, with a sword equipped |
| **Warlock talents** | Nightfall / Shadow Trance and Improved Shadow Bolt / Shadow Vulnerability |

View every effect in `/gpt list`. [CATALOG.md](CATALOG.md) contains the full
ID/source reference in German. Effects sharing a proc spell ID are grouped;
two identical weapons are counted together, not separately per hand.
This is an explicit catalog, not automatic recognition of every item or talent.
Active on-use abilities are not preconfigured as random procs.

<details>
<summary>🔎 How triggers are counted</summary>

- Buff applications and refreshes count; removals and ordinary stack changes do not.
- Target debuffs must originate from you. Selected armor-reduction effects also count stack gains.
- Damage procs count their damage or miss event, including resisted triggers. Periodic damage ticks do not count again.
- Lifestealing and Skullflame life drain count damage, not the associated healing.
- Extra attacks count once per trigger event, regardless of attacks granted. Ironfoe granting two attacks is one proc.
- Area effects group targets with the exact same combat-log timestamp; different timestamps cannot always be linked to one trigger.
- Shahram counts your summon, not its subsequent spells or party buffs.
- Quick Shots counts the buff, not accelerated shots; Rapid Fire is not included.
- Nightfall counts Shadow Trance, not consumption of the instant-cast benefit.
- Shadow Vulnerability counts your reported applications/refreshes, not charge consumption or every Shadow Bolt crit. It increases shadow damage taken rather than reducing resistance.

</details>

## 📤 Export your observations

Click **Export**, right-click the minimap icon or use `/gpt export`. Then
**`/reload` or log out** so WoW writes the character's file:

```text
_classic_era_/WTF/Account/<ACCOUNT>/<REALM>/<CHARACTER>/SavedVariables/GabbaProcTracker.lua
```

The snapshot is stored in `GabbaProcTrackerDB.export`. It contains cumulative
totals, combat exposure and retained history, plus a persistent **character UUID**,
a **collection ID** and an increasing **export sequence** for import deduplication.
An external importer must replace cumulative snapshots, not add repeated totals.

Each export replaces the previous snapshot without interrupting tracking. It
stays unchanged until the next export, even after a counter reset. A reset starts
a new collection but keeps the character UUID. Deleting SavedVariables creates
a new identity; copying the file copies it. Character name and realm are included.

**The addon does not upload data itself.** Use the optional companion from
[gabbaproc.kellerkind.info](https://gabbaproc.kellerkind.info) to upload selected
characters. The format is documented in [EXPORT.md](EXPORT.md). Since 0.1.2,
completed fights are retained in a separate archive beyond the 300-entry history
view, including collections preserved through counter resets. Previously trimmed
history cannot be recovered; the local detail archive now pauses at its structural budget, with a visible warning. Existing details remain available and counters continue. After a verified upload, use `/gpt archive clear confirm` to free local details.

For CSV, use `/gpt csv` or `/gpt csv history`, copy with Ctrl+A / Ctrl+C, and save
as UTF-8. Separator: semicolon; decimal separator: period. A missing rate means no
measured combat exposure; zero procs with positive exposure is a valid observation.

## 📊 Read the numbers correctly

**Procs per combat minute are not a proc chance per hit.** Attack speed, target
count, spell choices and equipment affect rates. Compare similar conditions and
collect enough combat time in each area. A higher observed rate does not prove
that the game's proc rules differ between areas.

Open World includes buildings and caves outside instances. Dungeons use instance
type `party`, raids use `raid`; battlegrounds and arenas are excluded. Tracking
runs from combat start to combat end, logout or a segment-splitting change.
Procs outside a combat segment appear in totals and zero-duration history records,
but not in combat-minute rates. Unsaved data can be lost in a client crash.

Hunter and warlock talent rates use all combat time with the talent learned,
including time without eligible attacks or with another hunter aspect active.
Sword Specialization additionally requires a sword. Custom effects are always
eligible for exposure tracking. Eligible attack attempts and confidence intervals
are not calculated.

## 🧩 Custom effects

Use the **proc spell ID**, not an item ID or enchantment recipe ID:

```text
/gpt add 12345 buff
/gpt add 12345 damage
/gpt add 12345 heal
/gpt add 12345 extra
/gpt remove 12345
```

Choose one matching event type per ID. `buff` is for your own buffs, not enemy
debuffs. Removing a custom effect stops tracking it and preserves existing counts.

## 🛠️ Development

```sh
bash tests/run_tests.sh
python3 -m unittest discover -s tests -p 'test_*.py' -v
python3 tools/build_package.py --tag v0.1.0
```

CI tests Lua 5.1 logic, both UI languages, exports, minimap behavior and packaging.
Tags produce GitHub release ZIPs and SHA256 checksums, with CurseForge uploads
when configured. See [RELEASING.md](RELEASING.md) and
[curseforge/PROJECT.md](curseforge/PROJECT.md).

Automated tests do not replace a real WoW client check. Visual/gameplay validation
is still pending. Classic Era / Hardcore is the supported target, not Retail,
progression Classic or Season of Discovery.

## 📄 License

[MIT](LICENSE) · Copyright © 2026 Nils (Gabbajoe).
The MIT file and CurseForge metadata were added after the initial v0.1.0 archive;
the published archive is preserved, and future packages include the license.

### Raid-test detail recording (0.1.3)

Version 0.1.3 adds numeric character/equipment/talent context, bounded stat/buff samples, attack outcomes and relative proc times per combat segment. Use **Companion 0.1.3 or newer** for the new SavedVariables export format. Old histories remain available, without retroactively inferred detail fields. See [EXPORT.md](EXPORT.md) for fields and limits. No target names/GUIDs are exported, and anonymous upload mode still excludes your character name and realm.
