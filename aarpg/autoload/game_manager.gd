extends Node

signal level_changed(index: int)
signal kills_changed(total: int)
signal combo_changed(count: int, multiplier: float)
signal combo_lost
signal combo_milestone(count: int)

const LEVEL_CONFIG = preload("res://aarpg/config/level_config.tres")

const DROP_LUCK_PER_STEP := 0.05
const DROP_LUCK_MAX := 2.5

@export var levels: Array[String] = [
	"res://aarpg/Levels/level_1_meadow.tscn",
	"res://aarpg/Levels/level_2_dungeon.tscn",
	"res://aarpg/Levels/level_3_boss.tscn",
	"res://aarpg/Levels/level_4_forest.tscn",
	"res://aarpg/Levels/level_5_graveyard.tscn",
	"res://aarpg/Levels/level_6_ice_arena.tscn",
	"res://aarpg/Levels/level_7_shadow_arena.tscn",
	"res://aarpg/Levels/level_8_ember_canyon.tscn",
	"res://aarpg/Levels/level_9_mystic_grove.tscn",
	"res://aarpg/Levels/level_10_exp_grind.tscn",
	"res://aarpg/Levels/level_11_venom_cavern.tscn",
	"res://aarpg/Levels/level_12_crystal_cavern.tscn",
	"res://aarpg/Levels/level_13_crystal_grind.tscn",
	"res://aarpg/Levels/level_14_abyssal_forge.tscn",
	"res://aarpg/Levels/level_15_sunken_abyss.tscn",
	"res://aarpg/Levels/level_16_goblin_grind.tscn",
	"res://aarpg/Levels/level_17_bone_grind.tscn",
	"res://aarpg/Levels/level_18_ember_grind.tscn",
	"res://aarpg/Levels/level_19_venom_grind.tscn",
	"res://aarpg/Levels/level_20_abyss_grind.tscn",
	"res://aarpg/Levels/level_21_ice_grind.tscn",
	"res://aarpg/Levels/level_22_shadow_grind.tscn",
	"res://aarpg/Levels/level_23_arcane_grind.tscn",
	"res://aarpg/Levels/level_24_wolf_den_grind.tscn",
	"res://aarpg/Levels/level_25_crystal_pit_grind.tscn",
	"res://aarpg/Levels/level_26_inferno_fortress_grind.tscn",
	"res://aarpg/Levels/level_27_shadow_nexus_grind.tscn",
	"res://aarpg/Levels/level_28_verdant_wilds_grind.tscn",
	"res://aarpg/Levels/level_29_abyss_maw_grind.tscn",
	"res://aarpg/Levels/level_30_frostpeak_grind.tscn",
	"res://aarpg/Levels/level_31_poison_bastion_grind.tscn",
	"res://aarpg/Levels/level_32_void_nexus_grind.tscn",
	"res://aarpg/Levels/level_33_bloodwave_grind.tscn",
	"res://aarpg/Levels/level_34_stormwave_grind.tscn",
	"res://aarpg/Levels/level_35_final_wave_grind.tscn",
	"res://aarpg/Levels/level_36_guardian_sentinel_grind.tscn",
	"res://aarpg/Levels/level_37_lich_court_grind.tscn",
]
@export var level_names: Array[String] = [
	"Meadow",
	"Dungeon",
	"Boss Arena",
	"Forest",
	"Graveyard",
	"Ice Cavern",
	"Shadow Keep",
	"Ember Canyon",
	"Mystic Grove",
	"EXP Grind Arena",
	"Venom Cavern",
	"Crystal Cavern",
	"Crystal Grind Pit",
	"Abyssal Forge",
	"Sunken Abyss",
	"Goblin Grind",
	"Bone Grind",
	"Ember Grind",
	"Venom Grind",
	"Abyss Grind",
	"Ice Grind",
	"Shadow Grind",
	"Arcane Grind",
	"Wolf Den",
	"Crystal Pit",
	"Inferno Fortress",
	"Shadow Nexus",
	"Verdant Wilds",
	"Abyss Maw",
	"Frostpeak",
	"Poison Bastion",
	"Void Nexus",
	"Bloodwave Arena",
	"Stormwave Arena",
	"Final Wave",
	"Guardian Sentinel",
	"Lich Court",
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
	current_level_index = clampi(index, 0, levels.size() - 1)
	_load_level(current_level_index)


func load_next_level() -> void:
	load_level(current_level_index + 1)


func restart_current_level() -> void:
	reset_combo()
	_load_level(current_level_index)


func get_level_name(index: int) -> String:
	if index < 0 or index >= level_names.size():
		return ""
	return level_names[index]


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
	get_tree().change_scene_to_file(levels[index])
