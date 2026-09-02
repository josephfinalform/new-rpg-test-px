extends Node

signal achievement_unlocked(id: String, title: String)

var _achievements: Dictionary = {}
var _unlocked: Dictionary = {}
const SAVE_PATH := "user://achievements.dat"


func _ready() -> void:
	_register_all()
	load_progress()


func _register_all() -> void:
	_register("first_blood", "First Blood", "Kill your first enemy")
	_register("combo_10", "Combo Frenzy", "Reach a 10-kill combo")
	_register("combo_25", "Combo Master", "Reach a 25-kill combo")
	_register("combo_50", "Combo Legend", "Reach a 50-kill combo")
	_register("level_10", "Rising Star", "Reach player level 10")
	_register("level_25", "Seasoned Warrior", "Reach player level 25")
	_register("level_50", "Halfway There", "Reach player level 50")
	_register("level_100", "Transcendent", "Reach max level")
	_register("boss_slayer", "Boss Slayer", "Defeat your first boss")
	_register("boss_hunter", "Boss Hunter", "Defeat 10 bosses")
	_register("boss_legend", "Boss Legend", "Defeat 50 bosses")
	_register("gold_100", "Pocket Change", "Collect 100 gold")
	_register("gold_1000", "Gold Hoarder", "Collect 1000 gold")
	_register("gold_10000", "Treasure King", "Collect 10000 gold")
	_register("grind_arena_5", "Grind Initiate", "Complete 5 grind arenas")
	_register("grind_arena_15", "Grind Veteran", "Complete 15 grind arenas")
	_register("grind_arena_32", "Grind Master", "Unlock all grind arenas")
	_register("kill_100", "Century Killer", "Kill 100 enemies")
	_register("kill_500", "Mass Slayer", "Kill 500 enemies")
	_register("kill_1000", "Genocide Champion", "Kill 1000 enemies")
	_register("prestige_1", "Prestige I", "Prestige for the first time")
	_register("prestige_5", "Prestige V", "Prestige 5 times")
	_register("speed_demon", "Speed Demon", "Clear any level in under 60 seconds")
	_register("untouchable", "Untouchable", "Clear a level without taking damage")
	_register("elemental_master", "Elemental Master", "Use all 3 element types in one combo")


func _register(id: String, title: String, desc: String) -> void:
	_achievements[id] = {"title": title, "description": desc}


func unlock(id: String) -> void:
	if _unlocked.has(id):
		return
	if not _achievements.has(id):
		return
	_unlocked[id] = true
	var data: Dictionary = _achievements[id]
	achievement_unlocked.emit(id, data["title"])
	save_progress()


func is_unlocked(id: String) -> bool:
	return _unlocked.has(id)


func get_all() -> Array[Dictionary]:
	var result: Array[Dictionary] = []
	for id in _achievements:
		var entry: Dictionary = _achievements[id].duplicate()
		entry["id"] = id
		entry["unlocked"] = _unlocked.has(id)
		result.append(entry)
	return result


func get_unlocked_count() -> int:
	return _unlocked.size()


func get_total_count() -> int:
	return _achievements.size()


func save_progress() -> void:
	var file = FileAccess.open(SAVE_PATH, FileAccess.WRITE)
	if file:
		file.store_var(_unlocked)
		file.close()


func load_progress() -> void:
	if not FileAccess.file_exists(SAVE_PATH):
		return
	var file = FileAccess.open(SAVE_PATH, FileAccess.READ)
	if file:
		var data = file.get_var()
		file.close()
		if data is Dictionary:
			_unlocked = data
