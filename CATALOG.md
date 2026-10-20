# Proc-Katalog – Classic Era / Hardcore

Stand: 20.10.2026, Version 0.1.2. **93 Effektgruppen**. Im Spiel: `/gpt list`.
Die Tabelle ist aus den tatsaechlich geladenen Definitionen erzeugt.
Englische Gegenstandsnamen dienen bei den recherchierten Ergaenzungen als
sprachunabhaengige Referenz; die Erkennung erfolgt ueber IDs.

## Recherche und Abgrenzung

- Schwertspezialisierung: [Krieger-Talent](https://www.wowhead.com/classic/spell=12813/sword-specialization), [Schurken-Talent](https://www.wowhead.com/classic/spell=13964/sword-specialization), gemeinsamer [Zusatzangriffs-Proc 16459](https://www.wowhead.com/classic/spell=16459/sword-specialization). Talent-IDs dienen nur zur Erkennung der Skillung, nicht als Proc-Zauber.
- Hexenmeister: [Einbruch der Nacht](https://github.com/wowsims/classic/blob/master/sim/warlock/talents.go), [Verbesserter Schattenblitz](https://www.wowhead.com/classic/spell=17793/improved-shadow-bolt), [Schattenverwundbarkeit](https://www.wowhead.com/classic/spell=17800/shadow-vulnerability).
- [WoWSims Classic: Gegenstandseffekte](https://github.com/wowsims/classic/blob/master/sim/common/item_effects.go): Item-/Proc-IDs und Art des Effekts. Der Quelltext enthaelt auch SoD-Aenderungen; diese wurden nicht automatisch uebernommen. Gepruefter Download SHA-256: `2d61364f1224fa45992322020b46afc198dcf9af081fbdf171491cb32936a8a7`.
- [WoWSims Classic: Verzauberungen](https://github.com/wowsims/classic/blob/master/sim/common/enchant_effects.go) und [Jaeger-Aspekte](https://github.com/wowsims/classic/blob/master/sim/hunter/aspects.go).
- [Shahram: Beschwoerung](https://www.wowhead.com/classic/spell=16602/shahram).
- Zusaetzlich direkt gepruefte Classic-Tooltips: [Uther's Strength](https://nether.wowhead.com/classic/tooltip/item/11302), [Buff 10368](https://nether.wowhead.com/classic/tooltip/spell/10368), [Force of Will](https://nether.wowhead.com/classic/tooltip/item/11810), [Buff 15595](https://nether.wowhead.com/classic/tooltip/spell/15595), [The Lion Horn of Stormwind](https://nether.wowhead.com/classic/tooltip/item/14557), [Buff 18946](https://nether.wowhead.com/classic/tooltip/spell/18946).

Das ist ein erweiterter, expliziter Katalog und keine Vollstaendigkeitsgarantie.
Aktive Benutzen-Effekte, permanente Statboni und nicht einzeln hinterlegte
Klassen-/Tier-/Set-Procs werden nicht automatisch erkannt. Einige Kandidaten
wie Quel'Serrar, Gutgore Ripper, Thunderstrike, Jeklik's Crusher, Flame Wrath
und Force Reactive Disk bleiben vorerst aus: die genutzten Quellen enthalten
abweichende SoD-IDs oder keine ausreichend eindeutig gepruefte Era-Ereignis-ID.

## Zaehllogik

- Schadens-Procs: einmal beim direkten Schaden oder gemeldeten Fehlschlag; keine erneute Zaehlung durch DoT-Ticks, Heilung oder Folge-Debuffs.
- Buffs: Anwendung/Erneuerung auf dir. Gegner-Debuffs: Anwendung/Erneuerung durch dich; nur bei entsprechend markierten Effekten auch Stack-Zunahmen. Auslaufen/Entfernen zaehlt nicht.
- Zusatzangriffe: ein Proc pro Ereignis, unabhaengig von der Anzahl gewaehrter Angriffe.
- Shahram: die eigene Beschwoerung zaehlt; Folgezauber des Geistes und fremde Beschwoerungen nicht.
- Mehrere Ziele werden bei markierten Flaecheneffekten ueber identische Combat-Log-Zeitstempel zusammengefasst. Getrennte Zeitstempel koennen zu Mehrfachzaehlung fuehren; mehrere echte Procs im gleichen Zeitstempel koennen zusammenfallen. Das muss ingame abgeglichen werden.
- Gemeinsame Zauber-IDs (Namen mit `/`) bilden eine Effektgruppe. Die Laufzeit wird gemessen, wenn mindestens einer der genannten Gegenstaende ausgeruestet ist. Eine eindeutige Zuordnung zu einer Waffe oder Hand wird nicht behauptet.
- Schnelle Schuesse: gesamte Kampfzeit mit gelerntem Talent, auch bei anderen Aspekten. Keine gemessene Chance pro Auto-Schuss.
- Schwertspezialisierung: alle Talentraenge beider Klassen; Kampfzeit mit gelerntem Talent und mindestens einem Schwert. Ein Ereignis zaehlt einmal, nicht nochmals beim ausgefuehrten Schlag.
- Hexenmeister-Talente: eigene Buff-/Debuff-Anwendung und Erneuerung; keine zusaetzliche Zaehlung bei verbrauchten Ladungen oder verbrauchter Schattentrance. Kampfzeit mit gelerntem Talent. Die niedrigeren Schattenverwundbarkeits-IDs 17794, 17798, 17797 und 17799 werden auf die gemeinsame Gruppe 17800 abgebildet. Es werden Debuff-Ereignisse erfasst, nicht alle Schattenblitz-Crits ungeachtet eines eventuell staerkeren fremden Debuffs.

Alle Eintraege sind anhand von Daten recherchiert; die automatisierten Tests
pruefen den Code mit simulierten Ereignissen, nicht das tatsaechliche
Combat-Log-Verhalten jedes einzelnen Gegenstands. Ein Ingame-Test steht aus.

## Vollstaendige Liste

| Effekt | Proc-Zauber-ID | Item-ID / Voraussetzung | Zaehlausloeser | Besonderheit |
| --- | --- | --- | --- | --- |
| Alcor's Sunrazor | 18833 | 14555 | SPELL_DAMAGE |  |
| Annihilator | 16928 | 12798 | Gegner-Debuff + Stack-Zunahme |  |
| Arcanite Champion | 16916 | 12790 | Eigener Buff |  |
| Argent Avenger | 17352 | 13246 | Eigener Buff |  |
| Barman Shanker / Blood Talon | 13318 | 12791, 12795 | Gegner-Debuff |  |
| Baron Charr's Sceptre | 13442 | 18671 | SPELL_DAMAGE |  |
| Bashguuder / Rivenspike | 17315 | 13204, 13286 | Gegner-Debuff + Stack-Zunahme |  |
| Blackhand Doomsaw | 16549 | 12583 | SPELL_DAMAGE |  |
| Blade of Eternal Darkness | 27860 | 17780 | SPELL_DAMAGE |  |
| Blazing Rapier | 16898 | 12777 | Gegner-Debuff |  |
| Bloodfist | 16433 | 11744 | SPELL_DAMAGE |  |
| Bloodletter Scalpel | 18081 | 9511 | SPELL_DAMAGE |  |
| Bloodrazor | 17504 | 809 | Gegner-Debuff |  |
| Bogen der sengenden Pfeile | 29638 | 2825 | SPELL_DAMAGE |  |
| Bonechill Hammer / Darrowspike | 18276 | 14487, 13984 | SPELL_DAMAGE |  |
| Chillpike | 19260 | 13148 | SPELL_DAMAGE |  |
| Coldrage Dagger / Hammer of the Northern Wind | 13439 | 10761, 810 | SPELL_DAMAGE |  |
| Deathbringer / Shadowblade | 18138 | 17068, 2163 | SPELL_DAMAGE |  |
| Destiny | 17152 | 647 | Eigener Buff |  |
| Dunkelmond: Blauer Drache | 23688 | 19288 | Eigener Buff |  |
| Dunkelmond: Heldentum | 23689 | 19287 | SPELL_HEAL |  |
| Dunkelmond: Mahlstrom | 23686 | 19289 | SPELL_DAMAGE |  |
| Ebenholzhand / Nightblade | 18211 | 19170, 1982 | SPELL_DAMAGE |  |
| Ebon Hilt of Marduk | 18656 | 14576 | Gegner-Debuff |  |
| Electrified Dagger | 23592 | 19100 | SPELL_DAMAGE |  |
| Emerald Dragonfang | 24993 | 20578 | SPELL_DAMAGE |  |
| Empyrean Demolisher | 21165 | 17112 | Eigener Buff |  |
| Eskhandar's Left Claw | 22639 | 18202 | Gegner-Debuff |  |
| Eskhandar's Right Claw | 22640 | 18203 | Eigener Buff |  |
| Fang of the Crystal Spider | 17331 | 13218 | Gegner-Debuff |  |
| Felstriker | 16551 | 12590 | Eigener Buff |  |
| Feurige Waffe | 13897 | Verzauberung 803 | SPELL_DAMAGE |  |
| Feuriger Schein | 6296 | Verzauberung 36 | SPELL_DAMAGE | Mehrere Ziele gruppiert |
| Fiery War Axe | 18796 | 870 | SPELL_DAMAGE |  |
| Firebreather | 16413 | 10797 | SPELL_DAMAGE |  |
| Force of Will | 15595 | 11810 | Eigener Buff |  |
| Frightalon | 19755 | 14024 | Gegner-Debuff |  |
| Frightskull Shaft | 18633 | 14531 | Gegner-Debuff |  |
| Frostguard | 16927 | 12797 | Gegner-Debuff |  |
| Glacial Blade | 18398 | 19099 | SPELL_DAMAGE |  |
| Gravestone War Axe | 18289 | 13983 | Gegner-Debuff |  |
| Gut Ripper | 18107 | 2164 | SPELL_DAMAGE |  |
| Gutwrencher / Hameya's Slayer | 16406 | 5616, 15814 | Gegner-Debuff |  |
| Hand der Gerechtigkeit | 15600 | 11815 | SPELL_EXTRA_ATTACKS |  |
| Hand von Edward dem Seltsamen: Fokus | 18803 | 2243 | Eigener Buff |  |
| Hanzo Sword / Vilerend Slicer | 16405 | 8190, 11603 | SPELL_DAMAGE |  |
| Hauklinge: Doppelschlag | 21919 | 17705 | SPELL_EXTRA_ATTACKS |  |
| Herz von Wyrmthalak | 27656 | 22321 | SPELL_DAMAGE |  |
| Hookfang Shanker | 13526 | 11635 | Gegner-Debuff |  |
| Ironfoe | 15494 | 11684 | SPELL_EXTRA_ATTACKS |  |
| Joonho's Mercy | 20883 | 17054 | SPELL_DAMAGE |  |
| Kalimdor's Revenge | 26415 | 21679 | SPELL_DAMAGE |  |
| Keris of Zul'Serak | 16528 | 12582 | Gegner-Debuff |  |
| Kreuzfahrer | 20007 | Verzauberung 1900 | Eigener Buff |  |
| Lebensdiebstahl | 20004 | Verzauberung 1898 | SPELL_DAMAGE |  |
| Linken's Sword of Mastery | 18089 | 11902 | SPELL_DAMAGE |  |
| Lord General's Sword | 15602 | 11817 | Eigener Buff |  |
| Mal der Auserwaehlten | 21970 | 17774 | Eigener Buff |  |
| Misplaced Servo Arm | 29150 | 23221 | SPELL_DAMAGE |  |
| Nightfall | 23605 | 19169 | Gegner-Debuff |  |
| Pendulum of Doom | 10373 | 9425 | SPELL_DAMAGE |  |
| Perdition's Blade | 23267 | 18816 | SPELL_DAMAGE |  |
| Ragehammer | 12686 | 10626 | Eigener Buff |  |
| Satyr's Lash | 18205 | 17752 | SPELL_DAMAGE |  |
| Schaedelflammenschild: Feuer | 18818 | 1168 | SPELL_DAMAGE | Mehrere Ziele gruppiert |
| Schaedelflammenschild: Lebensentzug | 18817 | 1168 | SPELL_DAMAGE |  |
| Schnelle Schuesse (Verb. Aspekt des Falken) | 6150 | Talent 19552 | Eigener Buff |  |
| Schattentrance (Einbruch der Nacht) | 17941 | Hexenmeister-Talent 18094 | Eigener Buff | Alle Talentraenge |
| Schattenverwundbarkeit (Verb. Schattenblitz) | 17800 | Hexenmeister-Talent 17793 | Eigener Gegner-Debuff | Alias-IDs 17794, 17798, 17797, 17799 |
| Schwertspezialisierung (Krieger/Schurke) | 16459 | Krieger-Talent 12281 / Schurken-Talent 13960 und Schwert | SPELL_EXTRA_ATTACKS | Beide Haende, alle Talentraenge |
| Schwarze Klinge von Shahram | 16602 | 12592 | SPELL_SUMMON |  |
| Searing Needle | 16454 | 12531 | SPELL_DAMAGE |  |
| Seeping Willow | 17196 | 12969 | Gegner-Debuff | Mehrere Ziele gruppiert |
| Serpent Slicer | 17511 | 13035 | Gegner-Debuff |  |
| Shortsword of Vengeance | 13519 | 754 | SPELL_DAMAGE |  |
| Skullforge Reaver | 17484 | 13361 | Gegner-Debuff |  |
| Sulfuras: Fireball | 21162 | 17182 | SPELL_DAMAGE |  |
| Sulfuron Hammer | 21159 | 17193 | SPELL_DAMAGE |  |
| Sword of Zeal | 8191 | 6622 | Eigener Buff |  |
| Teebu's Blazing Longsword | 18086 | 1728 | SPELL_DAMAGE |  |
| The Cruel Hand of Timmy | 17505 | 13401 | Gegner-Debuff |  |
| The Jackhammer | 13533 | 9423 | Eigener Buff |  |
| The Lion Horn of Stormwind | 18946 | 14557 | Eigener Buff |  |
| The Lobotomizer | 24388 | 19324 | SPELL_DAMAGE |  |
| The Untamed Blade | 23719 | 19334 | Eigener Buff |  |
| Thunderfury | 21992 | 19019 | SPELL_DAMAGE | Mehrere Ziele gruppiert |
| Uther's Strength | 10368 | 11302 | Eigener Buff |  |
| Venomspitter | 18203 | 13183 | Gegner-Debuff |  |
| Vis'kag the Bloodletter | 21140 | 17075 | SPELL_DAMAGE |  |
| Volcanic Hammer | 18082 | 12792 | SPELL_DAMAGE |  |
| Wirbelaxt: Zusatzangriff | 18797 | 871 | SPELL_EXTRA_ATTACKS |  |
| Wraith Scythe | 16414 | 11920 | SPELL_DAMAGE |  |
| Wrath of Cenarius | 25906 | 21190 | Eigener Buff |  |
