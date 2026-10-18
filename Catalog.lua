local _, ns = ...

-- Era IDs reviewed against wowsims/classic/sim/common/item_effects.go.
-- That source also contains SoD overrides: those IDs are deliberately excluded.
-- See CATALOG.md for coverage, grouping rules and independently checked entries.
local function Add(id, name, items, kind, stacks, aoe)
    assert(not ns.effects[id], "Duplicate proc spell: " .. id)
    ns.effects[id] = {
        name = name, items = type(items) == "table" and items or { items },
        aura = kind == "buff" or kind == "debuff",
        targetAura = kind == "debuff", stacks = stacks, aoe = aoe,
        event = kind == "damage" and "SPELL_DAMAGE" or nil,
        fixedName = true,
    }
end

-- Direct damage. Periodic damage/healing and secondary debuffs never count again.
Add(18833, "Alcor's Sunrazor", 14555, "damage")
Add(13442, "Baron Charr's Sceptre", 18671, "damage")
Add(16549, "Blackhand Doomsaw", 12583, "damage")
Add(27860, "Blade of Eternal Darkness", 17780, "damage")
Add(16433, "Bloodfist", 11744, "damage")
Add(18081, "Bloodletter Scalpel", 9511, "damage")
Add(18276, "Bonechill Hammer / Darrowspike", { 14487, 13984 }, "damage")
Add(19260, "Chillpike", 13148, "damage")
Add(13439, "Coldrage Dagger / Hammer of the Northern Wind", { 10761, 810 }, "damage")
Add(18138, "Deathbringer / Shadowblade", { 17068, 2163 }, "damage")
Add(23592, "Electrified Dagger", 19100, "damage")
Add(24993, "Emerald Dragonfang", 20578, "damage")
Add(18796, "Fiery War Axe", 870, "damage")
Add(16413, "Firebreather", 10797, "damage")
Add(18398, "Glacial Blade", 19099, "damage")
Add(18107, "Gut Ripper", 2164, "damage")
Add(16405, "Hanzo Sword / Vilerend Slicer", { 8190, 11603 }, "damage")
Add(20883, "Joonho's Mercy", 17054, "damage")
Add(26415, "Kalimdor's Revenge", 21679, "damage")
Add(18089, "Linken's Sword of Mastery", 11902, "damage")
Add(24388, "The Lobotomizer", 19324, "damage")
Add(29150, "Misplaced Servo Arm", 23221, "damage")
Add(10373, "Pendulum of Doom", 9425, "damage")
Add(23267, "Perdition's Blade", 18816, "damage")
Add(18205, "Satyr's Lash", 17752, "damage")
Add(16454, "Searing Needle", 12531, "damage")
Add(13519, "Shortsword of Vengeance", 754, "damage")
Add(21162, "Sulfuras: Fireball", 17182, "damage")
Add(21159, "Sulfuron Hammer", 17193, "damage")
Add(18086, "Teebu's Blazing Longsword", 1728, "damage")
Add(21992, "Thunderfury", 19019, "damage", false, true)
Add(21140, "Vis'kag the Bloodletter", 17075, "damage")
Add(18082, "Volcanic Hammer", 12792, "damage")
Add(16414, "Wraith Scythe", 11920, "damage")

-- Shared spell IDs cannot reliably be attributed to one equipped item.
ns.effects[18211].item = nil
ns.effects[18211].items = { 19170, 1982 }
ns.effects[18211].name = "Ebenholzhand / Nightblade"

-- Self buffs; healing portions of these procs are not counted separately.
Add(16916, "Arcanite Champion", 12790, "buff")
Add(17352, "Argent Avenger", 13246, "buff")
Add(17152, "Destiny", 647, "buff")
Add(21165, "Empyrean Demolisher", 17112, "buff")
Add(22640, "Eskhandar's Right Claw", 18203, "buff")
Add(15602, "Lord General's Sword", 11817, "buff")
Add(12686, "Ragehammer", 10626, "buff")
Add(8191, "Sword of Zeal", 6622, "buff")
Add(13533, "The Jackhammer", 9423, "buff")
Add(23719, "The Untamed Blade", 19334, "buff")
Add(25906, "Wrath of Cenarius", 21190, "buff")
-- Independently checked against Classic Wowhead item/buff tooltips.
Add(10368, "Uther's Strength", 11302, "buff")
Add(15595, "Force of Will", 11810, "buff")
Add(18946, "The Lion Horn of Stormwind", 14557, "buff")

-- Debuffs / pure DoTs: count application, refresh, and designated stack gains.
-- Never count periodic ticks or stack loss. Only player-owned applications count.
Add(16928, "Annihilator", 12798, "debuff", true)
Add(17315, "Bashguuder / Rivenspike", { 13204, 13286 }, "debuff", true)
Add(13318, "Barman Shanker / Blood Talon", { 12791, 12795 }, "debuff")
Add(16898, "Blazing Rapier", 12777, "debuff")
Add(17504, "Bloodrazor", 809, "debuff")
Add(18656, "Ebon Hilt of Marduk", 14576, "debuff")
Add(22639, "Eskhandar's Left Claw", 18202, "debuff")
Add(17331, "Fang of the Crystal Spider", 13218, "debuff")
Add(19755, "Frightalon", 14024, "debuff")
Add(18633, "Frightskull Shaft", 14531, "debuff")
Add(16927, "Frostguard", 12797, "debuff")
Add(18289, "Gravestone War Axe", 13983, "debuff")
Add(16406, "Gutwrencher / Hameya's Slayer", { 5616, 15814 }, "debuff")
Add(13526, "Hookfang Shanker", 11635, "debuff")
Add(16528, "Keris of Zul'Serak", 12582, "debuff")
Add(23605, "Nightfall", 19169, "debuff")
Add(17196, "Seeping Willow", 12969, "debuff", false, true)
Add(17511, "Serpent Slicer", 13035, "debuff")
Add(17484, "Skullforge Reaver", 13361, "debuff")
Add(17505, "The Cruel Hand of Timmy", 13401, "debuff")
Add(18203, "Venomspitter", 13183, "debuff")
