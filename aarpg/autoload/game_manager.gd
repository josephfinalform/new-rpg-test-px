extends Node

signal level_changed(index: int)
signal kills_changed(total: int)
signal combo_changed(count: int, multiplier: float)
signal combo_lost
signal combo_milestone(count: int)

const LEVEL_CONFIG = preload("res://aarpg/config/level_config.tres")
const LEVEL_REGISTRY = preload("res://aarpg/config/level_registry.gd")

const DROP_LUCK_PER_STEP := 0.05
const DROP_LUCK_MAX := 2.5

var level_registry = LEVEL_REGISTRY.new()

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


func load_index(index: int) -> void:
	current_level_index = _clamp_index(index)
	_load_level(current_level_index)


func load_next_level() -> void:
	load_index(get_next_level_index())


func get_next_level_index() -> int:
	if level_registry.is_last_level(current_level_index):
		return 0
	return current_level_index + 1


func _clamp_index(index: int) -> int:
	return clampi(index, 0, level_registry.get_level_count() - 1)


func restart_current_level() -> void:
	reset_combo()
	_load_level(current_level_index)


func get_level_count() -> int:
	return level_registry.get_level_count()


func get_level_path(index: int) -> String:
	return level_registry.get_level_path(index)


func get_level_name(index: int) -> String:
	return level_registry.get_level_name(index)


func get_level_subtitle(index: int) -> String:
	return level_registry.get_level_subtitle(index)


func get_map_indicator_text() -> String:
	return level_registry.get_map_indicator_text(current_level_index)


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
