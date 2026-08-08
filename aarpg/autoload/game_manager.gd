extends Node

signal level_changed(index: int)
signal kills_changed(total: int)

@export var levels: Array[String] = [
	"res://aarpg/Levels/level_1_meadow.tscn",
	"res://aarpg/Levels/level_2_dungeon.tscn",
	"res://aarpg/Levels/level_3_boss.tscn",
	"res://aarpg/Levels/level_4_forest.tscn",
	"res://aarpg/Levels/level_5_graveyard.tscn",
	"res://aarpg/Levels/level_6_ice_arena.tscn",
	"res://aarpg/Levels/level_8_ember_canyon.tscn",
	"res://aarpg/Levels/level_9_mystic_grove.tscn",
	"res://aarpg/Levels/level_7_shadow_arena.tscn",
]
@export var level_names: Array[String] = [
	"Meadow",
	"Dungeon",
	"Boss Arena",
	"Forest",
	"Graveyard",
	"Ice Cavern",
	"Ember Canyon",
	"Mystic Grove",
	"Shadow Keep",
]

var current_level_index: int = 0
var kills: int = 0
var equipped_weapon: Weapon = null
var equipped_armor: Armor = null


func start_game() -> void:
	current_level_index = 0
	kills = 0
	equipped_weapon = null
	equipped_armor = null
	kills_changed.emit(0)
	_load_level(current_level_index)


func load_level(index: int) -> void:
	current_level_index = clampi(index, 0, levels.size() - 1)
	_load_level(current_level_index)


func load_next_level() -> void:
	load_level(current_level_index + 1)


func restart_current_level() -> void:
	_load_level(current_level_index)


func get_level_name(index: int) -> String:
	if index < 0 or index >= level_names.size():
		return ""
	return level_names[index]


func enemy_killed() -> void:
	kills += 1
	kills_changed.emit(kills)


func _load_level(index: int) -> void:
	level_changed.emit(index)
	get_tree().change_scene_to_file(levels[index])
