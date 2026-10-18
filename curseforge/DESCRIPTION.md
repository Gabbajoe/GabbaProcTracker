![GabbaProcTracker](https://raw.githubusercontent.com/Gabbajoe/GabbaProcTracker/main/curseforge/logo.png)

# ⚡ GabbaProcTracker — Count the sparks!

**Track your procs. Compare Open World, dungeons and raids.**

![Classic Era and Hardcore](https://img.shields.io/badge/WoW-Classic_Era_%26_Hardcore-22d3ee?style=flat-square)
![English and German](https://img.shields.io/badge/Languages-English_%2F_Deutsch-fbbf24?style=flat-square)
![No dependencies](https://img.shields.io/badge/Dependencies-none-34d399?style=flat-square)
![Latest release](https://img.shields.io/github/v/release/Gabbajoe/GabbaProcTracker?style=flat-square&color=22d3ee&label=Release)

**📚 [Guide & controls](https://github.com/Gabbajoe/GabbaProcTracker/blob/main/README.md) · 💬 [Ideas & issues](https://github.com/Gabbajoe/GabbaProcTracker/issues)**

GabbaProcTracker is a standalone proc tracker for **World of Warcraft Classic
Era and Hardcore**. It counts supported weapon, shield, enchantment, trinket
and talent effects, then separates the results by the type of area you play in.
The interface automatically uses **German or English** based on your WoW client.

## ✨ Features

- Separate counters for **Open World, dungeons and raids**.
- **Procs per combat minute**, measured while the relevant equipment or talent
  is eligible. Zero-proc combat segments are included.
- A history of the **last 300 completed combat segments**, including zone,
  duration and proc counts. Cumulative totals remain available beyond that limit.
- **93 built-in effect groups**, plus custom proc spell IDs.
- A round, draggable **minimap button** with a matching addon icon.
- Per-character saved data and a persistent **character UUID**.
- **SavedVariables export snapshots** for external analysis, plus optional CSV.
- No required libraries or other addons. Tracking continues with the window closed.

## ⚔️ Supported effects

Examples include **Crusader, Fiery Weapon, Lifestealing, Felstriker, Ironfoe,
Thrash Blade, Flurry Axe, Hand of Edward the Odd, Ebon Hand, Skullflame Shield,
Blackblade of Shahram, Hand of Justice** and several Darkmoon Cards.

Talent effects include **Improved Aspect of the Hawk / Quick Shots**, warrior
and rogue **Sword Specialization**, and warlock **Nightfall / Shadow Trance**
and **Improved Shadow Bolt / Shadow Vulnerability**.

Effects that share a proc spell ID are grouped together. This is an explicit
catalog, not automatic recognition of every item. Use `/gpt list` to view all
supported effects, or `/gpt help` to add a custom proc by spell ID.

## 🧭 Getting started

- **Left-click the minimap button** or type `/gpt` to open the tracker.
- **Drag** the minimap button to move it. `/gpt minimap` hides or restores it.
- Choose **Counters**, **Procs / minute**, **History** or **Catalog**.
- **Right-click the minimap button**, click **Export**, or type `/gpt export`
  to save an analysis snapshot.

After exporting, use **`/reload` or log out** so WoW writes the SavedVariables file:

`WTF/Account/<ACCOUNT>/<REALM>/<CHARACTER>/SavedVariables/GabbaProcTracker.lua`

The snapshot contains cumulative totals and retained history. Its character UUID,
collection ID and export sequence allow an external importer to recognize repeat
imports. No web app or automatic upload is included. `/gpt csv` and
`/gpt csv history` provide copyable CSV as an alternative.

## 📊 Understanding the numbers

**Procs per combat minute are not a proc chance per hit.** Attack speed, number
of targets, spells used and equipment affect the observed rates. The addon does
not count eligible attack attempts or calculate statistical confidence intervals.
Battlegrounds and arenas are excluded; buildings and caves outside instances
count as Open World. Only your own supported triggers are counted.

Classic Era / Hardcore only. Retail, progression Classic and Season of Discovery
are not supported targets. Version 0.1.0 has automated logic and packaging tests;
real-client visual and gameplay checks are still pending.

## 🇩🇪 Deutsch

GabbaProcTracker zaehlt Waffen-, Schild-, Verzauberungs-, Trinket- und Talent-Procs
getrennt nach **Open World, Dungeons und Raids**. Dazu kommen Procs pro Kampfminute,
ein Verlauf der letzten 300 abgeschlossenen Kampfsegmente und ein Katalog mit
93 Effektgruppen. Die Gesamtwerte bleiben ueber das Verlaufslimit hinaus erhalten.

**Minimap:** Linksklick oeffnet das Fenster, Rechtsklick speichert den Export,
Ziehen verschiebt den Button. `/gpt minimap` blendet ihn aus oder wieder ein.
Nach einem Export `/reload` ausfuehren oder ausloggen. Die SavedVariables-Datei
enthaelt dann einen Snapshot fuer eine externe Auswertung. Eine Web-App ist
noch nicht enthalten. Die Charakter-UUID bleibt auch nach einem Zaehler-Reset erhalten.

Eine hoehere Proc-Rate ist eine Beobachtung und kein Beweis fuer unterschiedliche
Proc-Chancen zwischen Open World, Dungeons und Raids.
