# GabbaProcTracker

![GabbaProcTracker](curseforge/logo.png)

[Source](https://github.com/Gabbajoe/GabbaProcTracker) · [Releases](https://github.com/Gabbajoe/GabbaProcTracker/releases) · [Issues](https://github.com/Gabbajoe/GabbaProcTracker/issues)

Version **0.1.0**. Sprache automatisch Deutsch bei `deDE`, sonst Englisch.
Effekt- und Gegenstandsnamen kommen aus dem WoW-Client.

Eigenstaendiger Proc-Zaehler fuer WoW Classic Era / Hardcore (Interface 11509,
entsprechend den anderen Era-Addons in diesem Repository).

## Installation und Bedienung

Den Ordner `GabbaProcTracker` nach `_classic_era_/Interface/AddOns/` kopieren.
Das Spiel neu starten und das Addon in der Charakterauswahl aktivieren.
Mit `/gpt` oder `/gabbaprocs` das verschiebbare Fenster oeffnen.

Der runde **Minimap-Button** nutzt ein eigenes Icon mit transparenten Ecken:
Linksklick oeffnet/schliesst das Fenster, Rechtsklick speichert den Export.
Mit gedrueckter linker Maustaste verschieben; Position und Sichtbarkeit werden
pro Charakter gespeichert. `/gpt minimap` blendet den Button aus oder wieder ein.

- **Zaehler:** Ausloesungen getrennt nach Open World, Dungeons und Raids.
- **Procs / Minute:** Ausloesungen pro Kampfminute, waehrend der jeweilige
  Effekt ausgeruestet war. Maus ueber einer Zeile zeigt Procs und Kampfzeit.
- **Verlauf:** letzte 300 abgeschlossene Kampfsegmente, neueste zuerst,
  mit Datum/Uhrzeit, Effekt, Gruppe, Procs und Dauer. Maus ueber einer Zeile
  zeigt das Gebiet. Auch Segmente ohne Proc werden gespeichert.
- **Katalog** oder `/gpt list`: alle hinterlegten Effekte ansehen.

Das Addon zaehlt bei geschlossenem Fenster weiter. Daten werden pro Charakter
in SavedVariables gespeichert und bleiben bei Reload/Logout erhalten.
Gesamtzaehler und Kampfzeit bleiben auch erhalten, wenn alte Verlaufseintraege
aus dem 300-Segmente-Limit fallen. `/gpt reset confirm` loescht alle Messdaten
dieses Charakters, behaelt aber eigene Effektdefinitionen.

## Export fuer eine Web-App

Im Fenster **Export** anklicken oder `/gpt export` eingeben. Das speichert
Zusammenfassung und Verlauf gemeinsam unter `GabbaProcTrackerDB.export`.
Anschliessend **`/reload` oder ausloggen**, damit WoW die Datei schreibt:

```
_classic_era_/WTF/Account/<ACCOUNT>/<REALM>/<CHARAKTER>/SavedVariables/GabbaProcTracker.lua
```

Diese `.lua`-Datei kann spaeter in einer Web-App importiert werden. Ein
Datei-Upload/Importer ist noch nicht Teil dieses Addons. Es erfolgt kein Upload
aus dem Spiel. Das Exportformat ist in [EXPORT.md](EXPORT.md) dokumentiert.

Jeder Charakter besitzt eine dauerhaft gespeicherte **UUID**. Sie bleibt bei
Reload, Updates und Zaehler-Reset erhalten. Eine neue Messreihen-ID trennt Daten
nach einem Reset. Jeder Export bekommt eine fortlaufende Nummer. Wiederholte
Importe sollen in der Web-App aktualisieren, nicht die Gesamtzahlen addieren.
Loeschen der SavedVariables erzeugt eine neue Identitaet; eine Kopie behaelt sie.
Die UUID ist eine lokale Kennung, keine Anonymisierung: Name und Realm sind im Export.

Der Export ersetzt jeweils den letzten Snapshot. Er unterbricht die Messung
nicht und veraendert sich erst beim naechsten Export. Auch ein Reset behaelt den
letzten Snapshot, bis erneut exportiert wird. Die Gesamtzahlen enthalten die
gesamte Messreihe, der Detailverlauf maximal 300 abgeschlossene Segmente und
ein laufendes Segment. Alte Details werden nicht unbegrenzt archiviert.

Optional bleibt CSV zum Kopieren verfuegbar: `/gpt csv` fuer Summen und
`/gpt csv history` fuer den Verlauf. Strg+A/Strg+C, als UTF-8-Datei speichern;
Trennzeichen Semikolon, Dezimalpunkt. `/gpt export counts` und
`/gpt export history` speichern ebenfalls den vollstaendigen SavedVariables-Snapshot.

## Messung


Open World umfasst auch Haeuser und Hoehlen ausserhalb einer Instanz.
Dungeons entsprechen Instanztyp `party`, Raids `raid`. Schlachtfelder und Arenen
werden nicht erfasst. Die Gruppe wird beim Ereignis aus `IsInInstance()` gelesen.
Die Messung beginnt mit Spieler-Kampfbeginn und endet bei Kampfende, Logout,
Gebiets- oder Ausruestungswechsel. Ein Wechsel beginnt gegebenenfalls ein neues
Segment. Ein Reload waehrend des Kampfes beginnt nach dem Laden ein neues Segment.
Aktuelle Segmente erscheinen nach ihrem Abschluss im Verlauf.

Procs ausserhalb eines Kampfsegments erscheinen im Zaehler und als Eintrag mit
0 Sekunden, aber nicht in der Kampfminuten-Rate. Bei einem Client-Absturz koennen
noch nicht auf Platte gespeicherte Messdaten verloren gehen.

**Procs pro Minute sind keine Proc-Chance pro Treffer.** Angriffstempo,
Trefferzahl, Zauberauswahl, Ziele, Ausruestung und Kampfpausen unterscheiden sich
zwischen Gebieten. Eine hoehere Rate ist eine Beobachtung, kein Beweis fuer eine
andere Spielmechanik. Fuer einen aussagekraeftigen Vergleich in allen drei
Gruppen ausreichend Kampfzeit mit vergleichbarer Ausruestung sammeln.
Es werden keine ausloeseberechtigten Treffer/Zauber und keine Konfidenzintervalle
berechnet. Eigene Effekte gelten fuer die Zeitmessung immer als ausgeruestet.

## Eingebaute Effekte

Krieger/Schurke: **Schwertspezialisierung**, alle Talentraenge, ein Zaehler
fuer Proc-Zauber 16459. Die Kampfzeit wird nur mit gelerntem Talent und
mindestens einem ausgeruesteten Einhand- oder Zweihandschwert gemessen.
Haupt- und Nebenhand werden beruecksichtigt, aber nicht getrennt ausgezaehlt.
Hauklinge, Ironfoe und andere Gegenstands-Procs bleiben separate Effekte.

Hexenmeister: **Schattentrance / Einbruch der Nacht** (17941) und
**Schattenverwundbarkeit / Verbesserter Schattenblitz** (17800, mit Alias-IDs
17794, 17798, 17797 und 17799 fuer niedrigere Raenge). Anwendungen und
Erneuerungen werden gezaehlt; der verbrauchte Sofortzauber, Debuff-Ladungsverlust
und fremde Anwendungen zaehlen nicht erneut. Bei Schattenverwundbarkeit handelt
es sich um erhoehten erlittenen Schattenschaden, nicht um reduzierte Resistenz.
Die Rate bezieht sich jeweils auf die gesamte Kampfzeit mit gelerntem Talent.
Erfasst werden gemeldete eigene Debuff-Anwendungen/Erneuerungen, nicht pauschal
jeder Schattenblitz-Crit (etwa wenn ein staerkerer fremder Debuff nicht ersetzt wird).

Die vollstaendige Tabelle mit Gegenstands- und Zauber-IDs steht in
[CATALOG.md](CATALOG.md) und im Spiel unter `/gpt list`.
Der erweiterte Katalog deckt auch direkte Schadens-Procs, Blutungen,
Gegner-Debuffs und stapelbare Ruestungsreduktion ab. Gemeinsam verwendete
Zauber-IDs werden als gemeinsame Effektgruppe gezaehlt. Gegenstaende in allen
Ausruestungsplaetzen (einschliesslich Ringe und Fernkampf) werden beruecksichtigt.

Jaeger-Talent: **Verbesserter Aspekt des Falken / Schnelle Schuesse** (Buff 6150,
alle Talentraenge). Zaehlt Anwendung und Erneuerung des eigenen Buffs,
nicht jeden beschleunigten Schuss. Schnellfeuer (aktive Faehigkeit) ist separat
und wird hier nicht mitgezaehlt. Der Effekt wird bei gelerntem Talent erkannt.
Die Rate bezieht sich auf die gesamte Kampfzeit mit gelerntem Talent, also auch
Zeiten mit einem anderen Aspekt oder ohne Auto-Schuss. Diese Zeitbasis steht
auch im Tooltip; es ist keine Proc-Chance je Auto-Schuss.
Quelle: [Classic-Jaeger-Aspekte](https://github.com/wowsims/classic/blob/master/sim/hunter/aspects.go).

Waffen: Felstriker (Buff-Anwendung/Erneuerung), Ironfoe (ein Proc je
Zusatzangriffs-Ereignis, unabhaengig von der Anzahl gewaehrter Angriffe),
Ebenholzhand (Schattenschaden).
Hand von Edward dem Seltsamen (Fokus-Buff fuer den naechsten Sofortzauber),
Hauklinge / Thrash Blade (Doppelschlag) und Wirbelaxt / Flurry Axe (Zusatzangriff).
Bei Fokus wird die Buff-Ausloesung gezaehlt, nicht sein Verbrauch durch einen Zauber.
Schwarze Klinge von Shahram: ein Proc je eigener Beschwoerung
([Zauber 16602](https://www.wowhead.com/classic/spell=16602/shahram)), keine
zusaetzliche Zaehlung seiner Folgezauber oder Buffs auf Gruppenmitgliedern.
Die sechs moeglichen Folgeeffekte werden nicht einzeln ausgewertet.
Fernkampf: Bogen der sengenden Pfeile. Der Fernkampfslot wird fuer Erkennung und
Kampfzeit beruecksichtigt; andere Boegen, Schusswaffen und Armbrueste brauchen
weiterhin eine explizite Effektdefinition. Jäger koennen alle eingebauten
Trinket-Effekte nutzen; weitere Klassen- und Tierfaehigkeiten werden nicht automatisch erfasst.
Schilde: Schaedelflammenschild, mit getrennten Zeilen fuer Lebensentzug und Feuer.
Lebensentzug zaehlt nur das Schadensereignis, nicht die zusaetzliche Heilung.
Die Gegenstaende muessen ausgeruestet sein; die Waffenplaetze beider Haende
werden gelesen. Zwei gleiche Waffen werden zusammengefasst.

Waffenverzauberungen: Kreuzfahrer, Feurige Waffe, Feuriger Schein, Lebensdiebstahl.
Trinkets: Hand der Gerechtigkeit, Mal der Auserwaehlten, Dunkelmondkarten
Blauer Drache / Mahlstrom / Heldentum, Herz von Wyrmthalak, Uther's Strength,
Force of Will und The Lion Horn of Stormwind.

Das ist ein expliziter Katalog, keine automatische Erkennung aller Gegenstaende.
Aktive Benutzen-Effekte sind nicht als zufaellige Procs vorkonfiguriert.
IDs wurden mit den [Classic-Simulationsdaten fuer Verzauberungen](https://github.com/wowsims/classic/blob/master/sim/common/enchant_effects.go)
und [Gegenstaende](https://github.com/wowsims/classic/blob/master/sim/common/item_effects.go)
abgeglichen. Es wurde kein Simulationscode uebernommen.

Buffs zaehlen bei Anwendung/Erneuerung auf dem eigenen Charakter, nicht bei
Stack-Aenderungen. Gegner-Debuffs zaehlen nur von dir selbst ausgeloeste
Anwendungen/Erneuerungen (auch gemeldete Fehlschlaege); bei Annihilator und
Bashguuder/Rivenspike zaehlen auch Stack-Zunahmen. Periodische Schadensticks,
entfernte Stacks und auslaufende Buffs zaehlen nicht als erneuter Proc.
Schadens-Procs zaehlen ueber ihr Schadensereignis (auch
resistierte/verfehlte Ausloesungen). Lebensdiebstahl zaehlt nicht erneut bei
Heilung. Zusatzangriffe zaehlen pro Ausloesungsereignis, nicht pro gewaehrtem
Angriff. Flaecheneffekte im Katalog fassen Ziele mit identischem Combat-Log-Zeitstempel
zusammen; getrennte Zeitstempel lassen sich nicht sicher einem Proc zuordnen.
Kreuzfahrer auf zwei Waffen wird gemeinsam gezaehlt, ohne Zuordnung zur Hand.

Eigene Effekte lassen sich anhand ihrer **Proc-Zauber-ID**, nicht Item-ID oder
Verzauberungsrezept-ID, hinzufuegen:

```
/gpt add 12345 buff
/gpt add 12345 damage
/gpt add 12345 heal
/gpt add 12345 extra
/gpt remove 12345
```

Pro ID genau den passenden Ereignistyp verwenden. `buff` ist fuer eigene Buffs,
nicht fuer Debuffs auf Gegnern. Entfernen stoppt die Erfassung eines eigenen
Effekts; bereits gesammelte Daten bleiben sichtbar.

## Pruefung

Vom Repository-Hauptverzeichnis:
`lua GabbaProcTracker/tests/run.lua` und
`lua GabbaProcTracker/tests/export_test.lua`.
Die Tests pruefen Ereignisfilter, Gruppierung, Vermeidung von Doppelzaehlung,
Kampfzeit nur mit ausgeruesteten Effekten, Null-Proc-Kaempfe, Persistenz,
Verlaufslimit sowie das Laden und die Fenster-/Befehlslogik mit WoW-API-Mocks.
Ein echter Ingame-Test ist noch erforderlich: Effekt ausloesen, Fenster mit
Combat-Log vergleichen, Dungeon/Raid wechseln und Persistenz per `/reload`
pruefen. Die Mocks ersetzen keine visuelle Pruefung im WoW-Client.

## English quick start

Version **0.1.0**, WoW Classic Era / Hardcore. The UI uses German for deDE
and English for other client locales. Spell/item names follow the WoW client.
Open `/gpt`: Counters, Procs / minute, History, Catalog. Tracking continues
while the window is closed. World, dungeon and raid counters are separate.

Click **Export** or run `/gpt export`, then `/reload` or log out. Upload the
character's `WTF/Account/<ACCOUNT>/<REALM>/<CHARACTER>/SavedVariables/GabbaProcTracker.lua`
to a compatible future web importer. The snapshot is in `GabbaProcTrackerDB.export`.
No web importer or automatic upload is included. Each character has a persistent
UUID; resets start a new collection. Imports must replace cumulative snapshots,
not add them. Full totals are retained; detailed history is limited to the last
300 completed segments plus the current segment. Export again to update it.
See [EXPORT.md](EXPORT.md) for the schema. `/gpt csv [history]` opens optional CSV.

## Development and releases

From the repository directory: `bash tests/run_tests.sh`, then
`python3 -m unittest discover -s tests -p 'test_*.py' -v`.
Build: `python3 tools/build_package.py --tag v0.1.0`.
See [RELEASING.md](RELEASING.md) for CI, GitHub releases and CurseForge setup,
and [curseforge/PROJECT.md](curseforge/PROJECT.md) for project metadata.

Minimap: left-click toggles the window, right-click saves an export, drag moves
it; `/gpt minimap` toggles visibility. Position/visibility are saved per character.

## License / Lizenz

[MIT License](LICENSE), confirmed by the author on 2026-10-18.
