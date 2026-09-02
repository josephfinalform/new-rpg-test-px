class_name StormElemental
extends BossEnemy

@export_group("Storm Attacks")
@export var chain_lightning_cooldown: float = 3.5
@export var storm_cloud_cooldown: float = 6.0
@export var dash_cooldown: float = 4.0
@export var lightning_speed: float = 200.0
@export var lightning_damage: int = 2
@export var storm_cloud_damage: int = 1
@export var storm_cloud_duration: float = 2.0
@export var storm_cloud_radius: float = 50.0
@export var charge_speed: float = 250.0
@export var charge_duration: float = 0.5
@export var charge_damage: int = 3

var chain_lightning_timer: float = 0.0
var storm_cloud_timer: float = 0.0
var dash_timer: float = 0.0
var storm_cloud_active: bool = false
var storm_cloud_time: float = 0.0
var storm_cloud_tick: float = 0.0
var storm_cloud_pos: Vector2 = Vector2.ZERO
var attack_timers: Array[StringName] = [&"chain_lightning_timer", &"storm_cloud_timer", &"dash_timer"]

@onready var spawn_marker: Marker2D = $SpawnMarker

const _DATA := "res://aarpg/config/enemies/storm_elemental_data.tres"


func _get_data_path() -> String:
	return _DATA


func _is_special_active() -> bool:
	return dash_is_active or storm_cloud_active


func _process_special(delta: float) -> void:
	if dash_is_active:
		super(delta)
	elif storm_cloud_active:
		_process_storm_cloud(delta)


func _process_storm_cloud(delta: float) -> void:
	storm_cloud_time += delta
	storm_cloud_tick = max(0.0, storm_cloud_tick - delta)
	if has_valid_target() and storm_cloud_tick <= 0.0:
		if global_position.distance_to(chase_target.global_position) < storm_cloud_radius:
			chase_target.take_damage(storm_cloud_damage, global_position)
			storm_cloud_tick = 0.4
	velocity = Vector2.ZERO
	move_and_slide()
	if storm_cloud_time >= storm_cloud_duration:
		storm_cloud_active = false
		_end_cast()


func _evaluate_custom_attacks(dist: float) -> void:
	if dash_timer >= dash_cooldown and dist < 110 and dist > 45:
		begin_chase_dash(&"dash_timer", charge_speed, charge_duration, charge_damage)
		return
	if storm_cloud_timer >= storm_cloud_cooldown and dist < 120:
		_cast_storm_cloud()
		return
	if chain_lightning_timer >= chain_lightning_cooldown and dist < 160:
		_cast_chain_lightning()
		return


func _cast_chain_lightning() -> void:
	if not await _begin_cast(&"chain_lightning_timer", 0.3):
		return
	if has_valid_target():
		var dir = (chase_target.global_position - global_position).normalized()
		spawn_projectile(dir, lightning_speed, Color(0.3, 0.8, 1.0), Vector2(1.2, 1.2), spawn_marker)
		await get_tree().create_timer(0.15).timeout
		if not is_dead and has_valid_target():
			dir = (chase_target.global_position - global_position).normalized()
			spawn_projectile(dir, lightning_speed, Color(0.3, 0.8, 1.0), Vector2(0.9, 0.9), spawn_marker)
	_end_cast()


func _cast_storm_cloud() -> void:
	if not await _begin_cast(&"storm_cloud_timer", 0.4):
		return
	storm_cloud_active = true
	storm_cloud_time = 0.0
	storm_cloud_tick = 0.0
	storm_cloud_pos = global_position
	play_animation("move")


func _apply_phase_scaling() -> void:
	super()
	_scale_attack_cooldown(&"chain_lightning_cooldown", 1.2)
	_scale_attack_cooldown(&"storm_cloud_cooldown", 2.5)
	_scale_attack_cooldown(&"dash_cooldown", 1.5)
	if current_phase >= 2:
		lightning_damage = 3
		storm_cloud_damage = 2
