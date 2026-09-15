extends RefCounted

const LEVEL_RECORDS: Array[Dictionary] = [
	{"path": "res://aarpg/Levels/level_1_meadow.tscn", "name": "Meadow"},
	{"path": "res://aarpg/Levels/level_2_dungeon.tscn", "name": "Dungeon"},
	{"path": "res://aarpg/Levels/level_3_boss.tscn", "name": "Boss Arena"},
	{"path": "res://aarpg/Levels/level_4_forest.tscn", "name": "Forest"},
	{"path": "res://aarpg/Levels/level_5_graveyard.tscn", "name": "Graveyard"},
	{"path": "res://aarpg/Levels/level_6_ice_arena.tscn", "name": "Ice Cavern"},
	{"path": "res://aarpg/Levels/level_7_shadow_arena.tscn", "name": "Shadow Keep"},
	{"path": "res://aarpg/Levels/level_8_ember_canyon.tscn", "name": "Ember Canyon"},
	{"path": "res://aarpg/Levels/level_9_mystic_grove.tscn", "name": "Mystic Grove"},
	{"path": "res://aarpg/Levels/level_10_exp_grind.tscn", "name": "EXP Grind Arena"},
	{"path": "res://aarpg/Levels/level_11_venom_cavern.tscn", "name": "Venom Cavern"},
	{"path": "res://aarpg/Levels/level_12_crystal_cavern.tscn", "name": "Crystal Cavern"},
	{"path": "res://aarpg/Levels/level_13_crystal_grind.tscn", "name": "Crystal Grind Pit"},
	{"path": "res://aarpg/Levels/level_14_abyssal_forge.tscn", "name": "Abyssal Forge"},
	{"path": "res://aarpg/Levels/level_15_sunken_abyss.tscn", "name": "Sunken Abyss"},
	{"path": "res://aarpg/Levels/level_16_goblin_grind.tscn", "name": "Goblin Grind"},
	{"path": "res://aarpg/Levels/level_17_bone_grind.tscn", "name": "Bone Grind"},
	{"path": "res://aarpg/Levels/level_18_ember_grind.tscn", "name": "Ember Grind"},
	{"path": "res://aarpg/Levels/level_19_venom_grind.tscn", "name": "Venom Grind"},
	{"path": "res://aarpg/Levels/level_20_abyss_grind.tscn", "name": "Abyss Grind"},
	{"path": "res://aarpg/Levels/level_21_ice_grind.tscn", "name": "Ice Grind"},
	{"path": "res://aarpg/Levels/level_22_shadow_grind.tscn", "name": "Shadow Grind"},
	{"path": "res://aarpg/Levels/level_23_arcane_grind.tscn", "name": "Arcane Grind"},
	{"path": "res://aarpg/Levels/level_24_wolf_den_grind.tscn", "name": "Wolf Den"},
	{"path": "res://aarpg/Levels/level_25_crystal_pit_grind.tscn", "name": "Crystal Pit"},
	{"path": "res://aarpg/Levels/level_26_inferno_fortress_grind.tscn", "name": "Inferno Fortress"},
	{"path": "res://aarpg/Levels/level_27_shadow_nexus_grind.tscn", "name": "Shadow Nexus"},
	{"path": "res://aarpg/Levels/level_28_verdant_wilds_grind.tscn", "name": "Verdant Wilds"},
	{"path": "res://aarpg/Levels/level_29_abyss_maw_grind.tscn", "name": "Abyss Maw"},
	{"path": "res://aarpg/Levels/level_30_frostpeak_grind.tscn", "name": "Frostpeak"},
	{"path": "res://aarpg/Levels/level_31_poison_bastion_grind.tscn", "name": "Poison Bastion"},
	{"path": "res://aarpg/Levels/level_32_void_nexus_grind.tscn", "name": "Void Nexus"},
	{"path": "res://aarpg/Levels/level_33_bloodwave_grind.tscn", "name": "Bloodwave Arena"},
	{"path": "res://aarpg/Levels/level_34_stormwave_grind.tscn", "name": "Stormwave Arena"},
	{"path": "res://aarpg/Levels/level_35_final_wave_grind.tscn", "name": "Final Wave"},
	{"path": "res://aarpg/Levels/level_36_guardian_sentinel_grind.tscn", "name": "Guardian Sentinel"},
	{"path": "res://aarpg/Levels/level_37_lich_court_grind.tscn", "name": "Lich Court"},
	{"path": "res://aarpg/Levels/level_38_orc_warfront_grind.tscn", "name": "Orc Warfront"},
	{"path": "res://aarpg/Levels/level_39_goblin_warzone_grind.tscn", "name": "Goblin Warzone"},
	{"path": "res://aarpg/Levels/level_40_frost_legion_grind.tscn", "name": "Frost Legion"},
	{"path": "res://aarpg/Levels/level_41_shadow_vortex_grind.tscn", "name": "Shadow Vortex"},
	{"path": "res://aarpg/Levels/level_42_dragons_roost_grind.tscn", "name": "Dragon's Roost"},
	{"path": "res://aarpg/Levels/level_43_vampire_crypt_grind.tscn", "name": "Vampire Crypt"},
	{"path": "res://aarpg/Levels/level_44_storm_sanctum_grind.tscn", "name": "Storm Sanctum"},
	{"path": "res://aarpg/Levels/level_45_venom_citadel_grind.tscn", "name": "Venom Citadel"},
	{"path": "res://aarpg/Levels/level_46_crystal_anomaly_grind.tscn", "name": "Crystal Anomaly"},
	{"path": "res://aarpg/Levels/level_47_infernal_gate_grind.tscn", "name": "Infernal Gate"},
	{"path": "res://aarpg/Levels/level_48_abyssal_depths_grind.tscn", "name": "Abyssal Depths"},
	{"path": "res://aarpg/Levels/level_49_titans_crucible_grind.tscn", "name": "Titan's Crucible"},
	{"path": "res://aarpg/Levels/level_50_reapers_hollow_grind.tscn", "name": "Reaper's Hollow"},
	{"path": "res://aarpg/Levels/level_51_solar_throne_grind.tscn", "name": "Solar Throne"},
	{"path": "res://aarpg/Levels/level_52_eldritch_shrine_grind.tscn", "name": "Eldritch Shrine"},
	{"path": "res://aarpg/Levels/level_53_chrono_breach_grind.tscn", "name": "Chrono Breach"},
	{"path": "res://aarpg/Levels/level_54_gale_bastion_grind.tscn", "name": "Gale Bastion"},
	{"path": "res://aarpg/Levels/level_55_tomb_of_kings_grind.tscn", "name": "Tomb of Kings"},
	{"path": "res://aarpg/Levels/level_56_stormwrought_vault_grind.tscn", "name": "Stormwrought Vault"},
	{"path": "res://aarpg/Levels/level_57_prismatic_core_grind.tscn", "name": "Prismatic Core"},
	{"path": "res://aarpg/Levels/level_58_abyssal_arena_grind.tscn", "name": "Abyssal Arena", "subtitle": "The dark eye at the bottom of the world"},
	{"path": "res://aarpg/Levels/level_59_eternal_nexus.tscn", "name": "Eternal Nexus", "subtitle": "Beyond the loop — where all timelines converge"},
]


func get_level_count() -> int:
	return LEVEL_RECORDS.size()


func get_level_record(index: int) -> Dictionary:
	if not _is_valid_index(index):
		return {}
	return LEVEL_RECORDS[index]


func get_level_path(index: int) -> String:
	return str(get_level_record(index).get("path", ""))


func get_level_name(index: int) -> String:
	return str(get_level_record(index).get("name", ""))


func get_level_subtitle(index: int) -> String:
	return str(get_level_record(index).get("subtitle", ""))


func get_map_indicator_text(index: int) -> String:
	return "MAP %d / %d" % [index + 1, get_level_count()]


func is_last_level(index: int) -> bool:
	return index >= get_level_count() - 1


func _is_valid_index(index: int) -> bool:
	return index >= 0 and index < get_level_count()