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

@export_group("Wave Mode")
@export var is_wave_level: bool = false
@export var total_waves: int = 5
@export var enemies_per_wave_base: int = 8
@export var boss_wave_interval: int = 5

var _respawn_queue: Array[Dictionary] = []
var _scene_cache: Dictionary = {}
var _boss_respawn_banner: CanvasLayer = null
var _player: Player = null
var _wave_manager: ArenaWaveManager = null
var _level_start_time: float = 0.0

const BOSS_BANNER_COLOR := Color(1, 0.3, 0.3)
const BOSS_BANNER_FONT_SIZE := 28
const BOSS_BANNER_HOLD_TIME := 1.2
const BOSS_BANNER_FADE_TIME := 0.5


func _ready() -> void:
	_player = Player.find_in_tree(get_tree())
	if _player:
		_player.died.connect(_on_player_died)
		_player.global_position = player_spawn
	_level_start_time = Time.get_ticks_msec() / 1000.0
	if not boss.is_empty():
		var boss_node := _get_boss_node()
		if boss_node:
			boss_node.died.connect(_on_boss_died)
	if is_grind_level:
		_setup_grind_level()
	if is_wave_level:
		_setup_wave_level()
	_apply_difficulty_scaling()
	if is_final_level:
		_show_banner("BOSS", BOSS_BANNER_COLOR, BOSS_BANNER_FONT_SIZE, BOSS_BANNER_HOLD_TIME, BOSS_BANNER_FADE_TIME)
		_show_boss_banner_text()
	elif is_grind_level:
		_show_banner("EXP GRIND ARENA", Color(0.6, 0.9, 1.0), 26, 1.2, 0.5)
	elif is_wave_level:
		_show_banner("WAVE ARENA", Color(1.0, 0.6, 0.2), 26, 1.2, 0.5)


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
		_apply_grind_xp(enemy)
		var entry := {
			"scene_path": enemy.scene_file_path,
			"position": enemy.global_position,
			"is_boss": is_boss,
			"pending": false,
		}
		enemy.died.connect(_on_enemy_died.bind(entry))


func _apply_grind_xp(enemy: Enemy) -> void:
	enemy.xp_reward = roundi(float(enemy.xp_reward) * grind_xp_multiplier)
	if enemy is BossEnemy:
		var boss := enemy as BossEnemy
		boss.bonus_xp_reward = roundi(float(boss.bonus_xp_reward) * grind_xp_multiplier)


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
		return
	var scene: PackedScene = _scene_cache.get(scene_path)
	if scene == null:
		scene = load(scene_path) as PackedScene
		_scene_cache[scene_path] = scene
	if scene == null:
		return
	var container := get_node_or_null("Enemies")
	if container == null:
		container = self
	var new_enemy: Enemy = scene.instantiate()
	container.add_child(new_enemy)
	new_enemy.add_to_group("enemies")
	new_enemy.global_position = entry["position"]
	_apply_grind_xp(new_enemy)
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


func _create_overlay_label(text: String, color: Color, font_size: int, v_align: int = VERTICAL_ALIGNMENT_CENTER, bottom_offset: float = 0.0) -> Label:
	var overlay := CanvasLayer.new()
	overlay.layer = 10
	add_child(overlay)
	var label := Label.new()
	label.text = text
	label.add_theme_font_size_override("font_size", font_size)
	label.add_theme_color_override("font_color", color)
	label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	label.vertical_alignment = v_align
	label.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	if bottom_offset != 0.0:
		label.offset_bottom = bottom_offset
	overlay.add_child(label)
	return label


func _show_banner(text: String, color: Color, font_size: int = 28, hold_time: float = 1.2, fade_in: float = 0.5) -> void:
	var label := _create_overlay_label(text, color, font_size)
	label.modulate.a = 0.0
	var tween := label.create_tween()
	tween.tween_property(label, "modulate:a", 1.0, fade_in)
	tween.tween_interval(hold_time)
	tween.tween_property(label, "modulate:a", 0.0, 0.5)
	await tween.finished
	label.get_parent().queue_free()


func _get_boss_node() -> Node:
	return get_node_or_null(boss) if not boss.is_empty() else null


func _show_boss_banner_text() -> void:
	var boss_node := _get_boss_node()
	if boss_node and boss_node.has_method("get_boss_name"):
		_show_banner(boss_node.get_boss_name(), BOSS_BANNER_COLOR, BOSS_BANNER_FONT_SIZE, BOSS_BANNER_HOLD_TIME, BOSS_BANNER_FADE_TIME)


func _show_respawn_banner(delay: float) -> void:
	if _boss_respawn_banner and is_instance_valid(_boss_respawn_banner):
		_boss_respawn_banner.queue_free()
	var label := _create_overlay_label(
		"BOSS SLAIN - RESPAWNING IN %d s" % int(delay),
		Color(1.0, 0.7, 0.3), 20, VERTICAL_ALIGNMENT_BOTTOM, -50.0
	)
	_boss_respawn_banner = label.get_parent() as CanvasLayer


func _fade_out_respawn_banner() -> void:
	if _boss_respawn_banner and is_instance_valid(_boss_respawn_banner):
		var tween := _boss_respawn_banner.create_tween()
		tween.tween_property(_boss_respawn_banner, "modulate:a", 0.0, 0.5)
		tween.tween_callback(_boss_respawn_banner.queue_free)
		_boss_respawn_banner = null


func _show_gate_opened_banner() -> void:
	_show_banner("THE GATE IS OPEN!", Color(0.6, 1.0, 0.6), 22, 1.5, 0.4)


func _show_victory() -> void:
	_create_overlay_label("VICTORY!", Color(1.0, 0.84, 0.0), 36)
	await get_tree().create_timer(3.0).timeout
	GameManager.start_game()


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


func _setup_wave_level() -> void:
	_wave_manager = ArenaWaveManager.new()
	_wave_manager.total_waves = total_waves
	_wave_manager.enemies_per_wave_base = enemies_per_wave_base
	_wave_manager.boss_wave_interval = boss_wave_interval
	_wave_manager.wave_started.connect(_on_wave_started)
	_wave_manager.wave_cleared.connect(_on_wave_cleared)
	_wave_manager.all_waves_cleared.connect(_on_all_waves_cleared)
	add_child(_wave_manager)
	var enemy_scenes: Array[PackedScene] = []
	var boss_scene: PackedScene = null
	for enemy in get_tree().get_nodes_in_group("enemies"):
		if enemy.scene_file_path and not enemy.scene_file_path.is_empty():
			var sc = load(enemy.scene_file_path) as PackedScene
			if sc and enemy is BossEnemy:
				boss_scene = sc
			elif sc:
				enemy_scenes.append(sc)
	_wave_manager.setup(self, enemy_scenes, boss_scene)
	_wave_manager.start_waves()


func _on_wave_started(wave_number: int) -> void:
	_show_banner("WAVE %d" % wave_number, Color(1.0, 0.8, 0.2), 24, 0.8, 0.3)


func _on_wave_cleared(wave_number: int) -> void:
	_show_banner("WAVE %d CLEARED!" % wave_number, Color(0.3, 1.0, 0.5), 22, 1.0, 0.4)


func _on_all_waves_cleared() -> void:
	_show_banner("ALL WAVES CLEARED!", Color(1.0, 0.84, 0.0), 30, 2.0, 0.5)
	if is_final_level:
		await get_tree().create_timer(2.0).timeout
		_show_victory()


func get_level_elapsed_time() -> float:
	return (Time.get_ticks_msec() / 1000.0) - _level_start_time
