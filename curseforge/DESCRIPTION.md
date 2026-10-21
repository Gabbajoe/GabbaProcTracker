![GabbaProcTracker](https://raw.githubusercontent.com/Gabbajoe/GabbaProcTracker/main/curseforge/logo.png)

# ⚡ GabbaProcTracker — Count the sparks!

**Track your procs. Compare Open World, dungeons and raids.**

![Classic Era and Hardcore](https://img.shields.io/badge/WoW-Classic_Era_%26_Hardcore-22d3ee?style=flat-square)
![English and German](https://img.shields.io/badge/Languages-English_%2F_Deutsch-6ab3ff?style=flat-square)
![No dependencies](https://img.shields.io/badge/Dependencies-none-34d399?style=flat-square)

**[Community data & charts](https://gabbaproc.kellerkind.info/) · [Companion app](https://gabbaproc.kellerkind.info/downloads.html) · [Upload an export](https://gabbaproc.kellerkind.info/upload.html) · [Guide](https://github.com/Gabbajoe/GabbaProcTracker/blob/main/README.md)**

GabbaProcTracker counts your supported weapon, shield, enchantment, trinket and
talent procs in **World of Warcraft Classic Era and Hardcore**. See how your
observations differ between Open World, dungeons and raids. The addon works on
its own; contributing to the community collection is optional.

## ✨ What you can track

- Proc counts and **procs per combat minute**, separated by environment.
- Combat segments with duration and proc counts, including fights with no proc.
- A recent-history view in the addon and a **separate, persistent archive** for
  uploading completed segments. Leaving the recent-history view does not delete
  a segment from the archive.
- **93 built-in effect groups**, plus custom proc spell IDs for local tracking.
- For new recordings: proc timestamps, your attack outcomes and numeric context
  such as class, level, equipment, talents, stats and buffs. Detail recordings have
  per-segment limits and are marked when incomplete.
- Per-character saved data, an export button and optional automatic export on
  zone changes. Tracking continues while the window is closed.

Examples include **Crusader, Fiery Weapon, Lifestealing, Felstriker, Ironfoe,
Thrash Blade, Flurry Axe, Hand of Justice**, Darkmoon Cards, **Nightfall** and
**Sword Specialization**. Effects sharing a proc spell ID are grouped together.
Use the **Catalog** tab to see supported effects.

## 🧭 In game

1. Open the tracker with `/gpt` or **left-click the minimap button**.
2. Browse Counters, Procs / minute, History and Catalog.
3. Enable the **export on zone change checkbox** near the bottom of the window
   if you want snapshots refreshed automatically. `/gpt autoexport on` does the
   same thing. You can also click **Export** or right-click the minimap button.
4. **Use `/reload` or log out** before uploading: WoW writes the file to disk only
   then, even when automatic export is enabled.

The character file is located at:

`WTF/Account/<ACCOUNT>/<REALM>/<CHARACTER>/SavedVariables/GabbaProcTracker.lua`

Drag the minimap button to move it; `/gpt minimap` hides or restores it.
Escape closes the tracker window.

## 🌐 Share your observations — two ways

Sign in at **[gabbaproc.kellerkind.info](https://gabbaproc.kellerkind.info/account.html)**
and choose how to contribute:

- **Companion app for Windows, macOS or Linux:** finds your WoW installations,
  lets you select characters, previews the upload and can upload changed exports
  automatically. Interval and upload bandwidth are configurable.
- **Browser upload, without installing the companion:** open
  **[Upload export](https://gabbaproc.kellerkind.info/upload.html)**, select the
  character's `GabbaProcTracker.lua`, review the filtered preview and upload it.
  The original file is parsed locally in your browser, not executed or sent whole.

Choose a **pseudonymous upload** or publish your character name and realm.
Pseudonymous data still uses a stable character ID so repeated uploads do not
count twice. Uploading anonymously does not erase a name you previously published.
Only supported, explicitly allowed measurement fields are sent; no raw combat
logs, target names or target GUIDs. Custom effect IDs are not part of the public
catalog. The addon itself does not connect to the website.

Explore community measurements and charts by environment, segment duration and
class, including zero-proc segments and recorded proc timings. The analysis page
currently examines up to 500 recent archived segments; this is a query limit,
not an archive deletion limit.

## 📊 Reading the results

**Procs per combat minute are not a proc chance per hit.** Attack speed, targets,
spells, equipment and buffs affect observations. Recorded attack outcomes do not
by themselves identify every eligible proc opportunity. A higher observed rate
is not proof of different proc chances between environments.

Equipment changes can split one fight into several segments. Battlegrounds and
arenas are excluded. Tracking targets **Classic Era and Hardcore**; other WoW
editions are not supported. The local archive grows as you play. Data discarded
by older addon versions cannot be reconstructed.

## 🇩🇪 Deutsch

**Count the sparks!** GabbaProcTracker zählt deine Procs in **Classic Era und
Hardcore**, getrennt nach Open World, Dungeons und Raids. Du siehst Zähler,
Procs pro Kampfminute und einen Verlauf mit Dauer und Proc-Anzahl – auch für
Kämpfe ohne Proc. Abgeschlossene Segmente bleiben zusätzlich im dauerhaften
Exportarchiv erhalten, wenn sie aus der jüngsten Verlaufsliste verschwinden.

Öffne das Fenster mit `/gpt` oder per Linksklick auf den Minimap-Button. Unten im
Fenster aktiviert die **Checkbox für Export beim Gebietswechsel** automatische
Snapshots. Alternativ: **Export** anklicken oder den Minimap-Button rechtsklicken.
Danach immer **`/reload` oder ausloggen**, damit WoW die Datei tatsächlich schreibt.
Escape schließt das Fenster.

Auf **[gabbaproc.kellerkind.info](https://gabbaproc.kellerkind.info/)** sammeln und
vergleichen wir die Messungen gemeinsam. Nach der Anmeldung kannst du entweder
mit der **[Companion-App](https://gabbaproc.kellerkind.info/downloads.html)**
ausgewählte Charaktere automatisch synchronisieren oder die
**[Exportdatei direkt im Browser hochladen](https://gabbaproc.kellerkind.info/upload.html)**.
Vor dem Upload gibt es eine Vorschau und die Wahl zwischen pseudonymen Daten und
veröffentlichtem Charakternamen samt Realm. Die Teilnahme ist freiwillig; das
Addon funktioniert auch allein.

Neue Aufzeichnungen enthalten zusätzlich Proc-Zeitpunkte, Angriffsergebnisse
und begrenzte numerische Angaben zu Ausrüstung, Talenten, Werten und Buffs.
Ältere Kämpfe bekommen diese Details nicht nachträglich. Die Diagramme betrachten
zunächst bis zu 500 aktuelle Archivsegmente; gespeicherte Kämpfe werden dadurch
nicht gelöscht. Eine höhere Proc-Rate ist eine Beobachtung, kein Beweis für eine
andere Proc-Chance.

**[Source code](https://github.com/Gabbajoe/GabbaProcTracker) · [Ideas & issues](https://github.com/Gabbajoe/GabbaProcTracker/issues)**
