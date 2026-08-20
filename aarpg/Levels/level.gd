class_name Level
extends Node2D

@export var player_spawn: Vector2 = Vector2(64, 64)
@export var is_final_level: bool = false
@export var boss: NodePath
@export var boss_gate_portal: NodePath

@export_group("EXP Grind Arena")
@export var is_grind_level: bool = false
@export var grind_xp_multiplier: float = 2.0
@export var enemy_respawn_delay: float = 6.0
@export var boss_respawn_delay: float = 25.0

var _spawn_entries: Array[Dictionary] = []
var _respawn_queue: Array[Dictionary] = []
var _boss_respawn_banner: CanvasLayer = null
var _player: Player = null


func _ready() -> void:
	_player = _find_player()
	if _player:
		_player.died.connect(_on_player_died)
		_player.global_position = player_spawn
	if not boss.is_empty():
		var boss_node := get_node_or_null(boss)
		if boss_node:
			boss_node.died.connect(_on_boss_died)
	if is_grind_level:
		_setup_grind_level()
	_apply_difficulty_scaling()
	if is_final_level:
		_show_banner("BOSS", Color(1, 0.3, 0.3), 28, 1.2, 0.5)
		_show_boss_banner_text()
	elif is_grind_level:
		_show_banner("EXP GRIND ARENA", Color(0.6, 0.9, 1.0), 26, 1.2, 0.5)


func _process(delta: float) -> void:
	if not is_grind_level or _respawn_queue.is_empty():
		return
	for i in range(_respawn_queue.size() - 1, -1, -1):
		var entry: Dictionary = _respawn_queue[i]
		entry["time_left"] = float(entry["time_left"]) - delta
		if entry["time_left"] <= 0.0:
			_respawn_entry(entry)
			_respawn_queue.remove_at(i)


func _setup_grind_level() -> void:
	for enemy in get_tree().get_nodes_in_group("enemies"):
		if not enemy is Enemy:
			continue
		var is_boss := enemy is BossEnemy
		enemy.xp_reward = roundi(float(enemy.xp_reward) * grind_xp_multiplier)
		if is_boss:
			enemy.bonus_xp_reward = roundi(float(enemy.bonus_xp_reward) * grind_xp_multiplier)
		var entry := {
			"scene_path": enemy.scene_file_path,
			"position": enemy.global_position,
			"is_boss": is_boss,
			"pending": false,
		}
		_spawn_entries.append(entry)
		enemy.died.connect(_on_enemy_died.bind(entry))


func _on_enemy_died(entry: Dictionary) -> void:
	if entry.get("pending", false):
		return
	entry["pending"] = true
	var delay := boss_respawn_delay if entry["is_boss"] else enemy_respawn_delay
	entry["time_left"] = delay
	_respawn_queue.append(entry)
	if entry["is_boss"]:
		_show_respawn_banner(delay)


func _respawn_entry(entry: Dictionary) -> void:
	entry["pending"] = false
	var scene_path: String = entry.get("scene_path", "")
	if scene_path.is_empty():
		_spawn_entries.erase(entry)
		return
	var scene := load(scene_path) as PackedScene
	if scene == null:
		_spawn_entries.erase(entry)
		return
	var container := get_node_or_null("Enemies")
	if container == null:
		container = self
	var new_enemy: Enemy = scene.instantiate()
	container.add_child(new_enemy)
	new_enemy.global_position = entry["position"]
	new_enemy.xp_reward = roundi(float(new_enemy.xp_reward) * grind_xp_multiplier)
	if entry["is_boss"]:
		var boss_enemy := new_enemy as BossEnemy
		boss_enemy.bonus_xp_reward = roundi(float(boss_enemy.bonus_xp_reward) * grind_xp_multiplier)
	new_enemy.died.connect(_on_enemy_died.bind(entry))
	if new_enemy.has_method("apply_level_scaling"):
		new_enemy.apply_level_scaling(GameManager.current_level_index)
	if entry["is_boss"]:
		_fade_out_respawn_banner()


func _apply_difficulty_scaling() -> void:
	var index := GameManager.current_level_index
	if index <= 0:
		return
	for enemy in get_tree().get_nodes_in_group("enemies"):
		if enemy.has_method("apply_level_scaling"):
			enemy.apply_level_scaling(index)


func _show_banner(text: String, color: Color, font_size: int = 28, hold_time: float = 1.2, fade_in: float = 0.5) -> void:
	var overlay := CanvasLayer.new()
	overlay.layer = 10
	add_child(overlay)
	var label := Label.new()
	label.text = text
	label.add_theme_font_size_override("font_size", font_size)
	label.add_theme_color_override("font_color", color)
	label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	label.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	label.modulate.a = 0.0
	overlay.add_child(label)
	var tween := label.create_tween()
	tween.tween_property(label, "modulate:a", 1.0, fade_in)
	tween.tween_interval(hold_time)
	tween.tween_property(label, "modulate:a", 0.0, 0.5)
	await tween.finished
	overlay.queue_free()


func _show_boss_banner_text() -> void:
	if not boss.is_empty():
		var boss_node := get_node_or_null(boss)
		if boss_node and boss_node.has_method("get_boss_name"):
			_show_banner(boss_node.get_boss_name(), Color(1, 0.3, 0.3), 28, 1.2, 0.5)


func _show_respawn_banner(delay: float) -> void:
	if _boss_respawn_banner and is_instance_valid(_boss_respawn_banner):
		_boss_respawn_banner.queue_free()
	_boss_respawn_banner = CanvasLayer.new()
	_boss_respawn_banner.layer = 10
	add_child(_boss_respawn_banner)
	var label := Label.new()
	label.text = "BOSS SLAIN - RESPAWNING IN %d s" % int(delay)
	label.add_theme_font_size_override("font_size", 20)
	label.add_theme_color_override("font_color", Color(1.0, 0.7, 0.3))
	label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	label.vertical_alignment = VERTICAL_ALIGNMENT_BOTTOM
	label.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	label.offset_bottom = -50
	_boss_respawn_banner.add_child(label)


func _fade_out_respawn_banner() -> void:
	if _boss_respawn_banner and is_instance_valid(_boss_respawn_banner):
		var tween := _boss_respawn_banner.create_tween()
		tween.tween_property(_boss_respawn_banner, "modulate:a", 0.0, 0.5)
		tween.tween_callback(_boss_respawn_banner.queue_free)
		_boss_respawn_banner = null


func _show_gate_opened_banner() -> void:
	_show_banner("THE GATE IS OPEN!", Color(0.6, 1.0, 0.6), 22, 1.5, 0.4)


func _show_victory() -> void:
	var overlay := CanvasLayer.new()
	overlay.layer = 10
	add_child(overlay)
	var label := Label.new()
	label.text = "VICTORY!"
	label.add_theme_font_size_override("font_size", 36)
	label.add_theme_color_override("font_color", Color(1.0, 0.84, 0.0))
	label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	label.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	overlay.add_child(label)
	await get_tree().create_timer(3.0).timeout
	GameManager.start_game()


func _find_player() -> Player:
	var players := get_tree().get_nodes_in_group("player")
	if players.size() > 0:
		return players[0] as Player
	return null


func _on_player_died() -> void:
	await get_tree().create_timer(1.2).timeout
	GameManager.restart_current_level()


func _on_boss_died() -> void:
	if is_final_level:
		_show_victory()
	elif not boss_gate_portal.is_empty():
		var portal_node := get_node_or_null(boss_gate_portal)
		if portal_node and portal_node.has_method("unlock"):
			portal_node.unlock()
			_show_gate_opened_banner()
