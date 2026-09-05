extends Node

signal level_changed(index: int)
signal kills_changed(total: int)
signal combo_changed(count: int, multiplier: float)
signal combo_lost
signal combo_milestone(count: int)

const LEVEL_CONFIG = preload("res://aarpg/config/level_config.tres")

const DROP_LUCK_PER_STEP := 0.05
const DROP_LUCK_MAX := 2.5

@export var level_records: Array[Dictionary] = [
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
]

var current_level_index: int = 0
var kills: int = 0
var equipped_weapon: Weapon = null
var equipped_armor: Armor = null
var combo: int = 0
var combo_time_left: float = 0.0


func _process(delta: float) -> void:
	if combo <= 0:
		return
	combo_time_left -= delta
	if combo_time_left <= 0.0:
		combo = 0
		combo_lost.emit()


func start_game() -> void:
	current_level_index = 0
	kills = 0
	combo = 0
	combo_time_left = 0.0
	equipped_weapon = null
	equipped_armor = null
	GoldManager.reset()
	kills_changed.emit(0)
	_load_level(current_level_index)


func load_level(index: int) -> void:
	current_level_index = clampi(index, 0, level_records.size() - 1)
	_load_level(current_level_index)


func load_next_level() -> void:
	load_level(current_level_index + 1)


func restart_current_level() -> void:
	reset_combo()
	_load_level(current_level_index)


func get_level_count() -> int:
	return level_records.size()


func get_level_path(index: int) -> String:
	if index < 0 or index >= level_records.size():
		return ""
	return str(level_records[index]["path"])


func get_level_name(index: int) -> String:
	if index < 0 or index >= level_records.size():
		return ""
	return str(level_records[index]["name"])


func enemy_killed() -> void:
	kills += 1
	kills_changed.emit(kills)
	combo += 1
	combo_time_left = LEVEL_CONFIG.combo_window_time
	combo_changed.emit(combo, get_combo_multiplier())
	if combo % 5 == 0:
		combo_milestone.emit(combo)


func get_combo_multiplier() -> float:
	return minf(1.0 + float(combo) * LEVEL_CONFIG.combo_xp_per_step, LEVEL_CONFIG.combo_max_multiplier)


func get_drop_luck() -> float:
	return minf(1.0 + float(combo) * DROP_LUCK_PER_STEP, DROP_LUCK_MAX)


func reset_combo() -> void:
	if combo <= 0:
		return
	combo = 0
	combo_time_left = 0.0
	combo_lost.emit()


func _load_level(index: int) -> void:
	level_changed.emit(index)
	get_tree().change_scene_to_file(get_level_path(index))
