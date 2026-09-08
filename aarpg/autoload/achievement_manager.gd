extends Node

signal achievement_unlocked(id: String, title: String)

var _achievements: Dictionary = {}
var _unlocked: Dictionary = {}
var _bosses_killed: int = 0
var _boss_hook_attempts: int = 0
const SAVE_PATH := "user://achievements.dat"


func _ready() -> void:
	_register_all()
	load_progress()
	GameManager.kills_changed.connect(_on_kills_changed)
	GameManager.combo_milestone.connect(_on_combo_milestone)
	GameManager.level_changed.connect(_on_level_changed)
	GoldManager.gold_changed.connect(_on_gold_changed)
	GameManager.level_changed.connect(_schedule_hook)


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
	_register("arena_50", "Beyond the Veil", "Reach the endgame wave arenas")
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


func _on_kills_changed(kills: int) -> void:
	if kills >= 1:
		unlock("first_blood")
	if kills >= 100:
		unlock("kill_100")
	if kills >= 500:
		unlock("kill_500")
	if kills >= 1000:
		unlock("kill_1000")


func _on_combo_milestone(combo: int) -> void:
	if combo >= 10:
		unlock("combo_10")
	if combo >= 25:
		unlock("combo_25")
	if combo >= 50:
		unlock("combo_50")


func _on_gold_changed(gold: int) -> void:
	if gold >= 100:
		unlock("gold_100")
	if gold >= 1000:
		unlock("gold_1000")
	if gold >= 10000:
		unlock("gold_10000")


func _on_player_level(level: int) -> void:
	if level >= 10:
		unlock("level_10")
	if level >= 25:
		unlock("level_25")
	if level >= 50:
		unlock("level_50")
	if level >= 100:
		unlock("level_100")


func _on_level_changed(index: int) -> void:
	if index >= 5:
		unlock("grind_arena_5")
	if index >= 15:
		unlock("grind_arena_15")
	if index >= 32:
		unlock("grind_arena_32")
	if index >= 49:
		unlock("arena_50")


func _on_boss_died() -> void:
	_bosses_killed += 1
	if _bosses_killed >= 1:
		unlock("boss_slayer")
	if _bosses_killed >= 10:
		unlock("boss_hunter")
	if _bosses_killed >= 50:
		unlock("boss_legend")
	save_progress()


func _schedule_hook(_index: int) -> void:
	_boss_hook_attempts = 0
	_hook_scene_nodes()


func _hook_scene_nodes() -> void:
	var player := Player.find_in_tree(get_tree())
	var hooked_boss := false
	for node in get_tree().get_nodes_in_group("enemies"):
		if node is BossEnemy and not node.died.is_connected(_on_boss_died):
			node.died.connect(_on_boss_died)
			hooked_boss = true
	if player == null and not hooked_boss:
		_boss_hook_attempts += 1
		if _boss_hook_attempts < 60:
			await get_tree().create_timer(0.05).timeout
			_hook_scene_nodes()
		return
	if player:
		if not player.level_up.is_connected(_on_player_level):
			player.level_up.connect(_on_player_level)


func save_progress() -> void:
	var file = FileAccess.open(SAVE_PATH, FileAccess.WRITE)
	if file:
		file.store_var({"unlocked": _unlocked, "bosses": _bosses_killed})
		file.close()


func load_progress() -> void:
	if not FileAccess.file_exists(SAVE_PATH):
		return
	var file = FileAccess.open(SAVE_PATH, FileAccess.READ)
	if file:
		var data = file.get_var()
		file.close()
		if data is Dictionary:
			if data.has("unlocked") and data["unlocked"] is Dictionary:
				_unlocked = data["unlocked"]
				_bosses_killed = int(data.get("bosses", 0))
			else:
				_unlocked = data