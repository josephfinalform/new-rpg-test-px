extends Node
class_name ArenaWaveManager

signal wave_started(wave_number: int)
signal wave_cleared(wave_number: int)
signal all_waves_cleared

@export var total_waves: int = 5
@export var enemies_per_wave_base: int = 8
@export var enemies_per_wave_growth: int = 3
@export var wave_spawn_delay: float = 1.5
@export var intermission_time: float = 3.0
@export var boss_wave_interval: int = 5
@export var wave_xp_bonus_per_clear: float = 0.1

var current_wave: int = 0
var _enemies_alive: int = 0
var _spawn_queue: Array[Dictionary] = []
var _spawn_timer: float = 0.0
var _waiting_for_clear: bool = false
var _level_ref: Node = null

var _enemy_scenes: Array[PackedScene] = []
var _boss_scene: PackedScene = null


func setup(level: Node, enemy_scenes: Array[PackedScene], boss_scene: PackedScene = null) -> void:
	_level_ref = level
	_enemy_scenes = enemy_scenes
	_boss_scene = boss_scene
	current_wave = 0
	_enemies_alive = 0
	_spawn_queue.clear()
	_waiting_for_clear = false


func start_waves() -> void:
	_advance_wave()


func _advance_wave() -> void:
	current_wave += 1
	if current_wave > total_waves:
		all_waves_cleared.emit()
		return
	wave_started.emit(current_wave)
	_waiting_for_clear = false
	_spawn_wave_enemies()


func _spawn_wave_enemies() -> void:
	var count: int = enemies_per_wave_base + enemies_per_wave_growth * (current_wave - 1)
	var is_boss_wave: bool = current_wave % boss_wave_interval == 0 and _boss_scene != null
	if is_boss_wave:
		count = maxi(count / 2, 3)

	for i in range(count):
		var scene: PackedScene
		if is_boss_wave and i == 0:
			scene = _boss_scene
		else:
			scene = _enemy_scenes[randi() % _enemy_scenes.size()] if _enemy_scenes.size() > 0 else null
		if scene == null:
			continue
		var spawn_pos := Vector2(randf_range(100, 1400), randf_range(100, 650))
		_spawn_queue.append({"scene": scene, "position": spawn_pos, "delay": float(i) * wave_spawn_delay})

	_spawn_timer = 0.0
	set_process(true)


func _process(delta: float) -> void:
	if _spawn_queue.is_empty():
		if _waiting_for_clear and _enemies_alive <= 0:
			set_process(false)
			wave_cleared.emit(current_wave)
			await get_tree().create_timer(intermission_time).timeout
			_advance_wave()
		return
	_spawn_timer += delta
	while not _spawn_queue.is_empty() and _spawn_timer >= _spawn_queue[0]["delay"]:
		var entry: Dictionary = _spawn_queue.pop_front()
		_spawn_enemy(entry["scene"], entry["position"])
	if _spawn_queue.is_empty():
		_waiting_for_clear = true


func _spawn_enemy(scene: PackedScene, pos: Vector2) -> void:
	if _level_ref == null or not is_instance_valid(_level_ref):
		return
	var enemy: Node = scene.instantiate()
	var container := _level_ref.get_node_or_null("Enemies")
	if container == null:
		container = _level_ref
	container.add_child(enemy)
	enemy.add_to_group("enemies")
	enemy.global_position = pos
	_enemies_alive += 1
	if enemy.has_signal("died"):
		enemy.died.connect(_on_enemy_died)


func _on_enemy_died() -> void:
	_enemies_alive = maxi(_enemies_alive - 1, 0)


func get_xp_multiplier() -> float:
	return 1.0 + wave_xp_bonus_per_clear * float(current_wave - 1)
