class_name FireDragon
extends BossEnemy

@export_group("Dragon Attacks")
@export var fireball_cooldown: float = 2.0
@export var flame_breath_cooldown: float = 6.0
@export var charge_cooldown: float = 4.5
@export var fireball_speed: float = 130.0
@export var flame_breath_damage: int = 2
@export var flame_breath_duration: float = 1.2
@export var charge_speed: float = 280.0
@export var charge_duration: float = 0.6
@export var charge_damage: int = 4

var fireball_timer: float = 0.0
var flame_breath_timer: float = 0.0
var charge_timer: float = 0.0
var flame_breath_active: bool = false
var flame_breath_time: float = 0.0
var flame_breath_tick: float = 0.0
var attack_timers: Array[StringName] = [&"fireball_timer", &"flame_breath_timer", &"charge_timer"]

@onready var spawn_marker: Marker2D = $SpawnMarker

const _DATA := "res://aarpg/config/enemies/fire_dragon_data.tres"


func _get_data_path() -> String:
	return _DATA


func _is_special_active() -> bool:
	return dash_is_active or flame_breath_active


func _process_special(delta: float) -> void:
	if dash_is_active:
		super(delta)
	elif flame_breath_active:
		_process_flame_breath(delta)


func _process_flame_breath(delta: float) -> void:
	flame_breath_time += delta
	flame_breath_tick = max(0.0, flame_breath_tick - delta)
	if has_valid_target() and flame_breath_tick <= 0.0:
		if global_position.distance_to(chase_target.global_position) < 80:
			chase_target.take_damage(flame_breath_damage, global_position)
			flame_breath_tick = 0.3
	velocity = Vector2.ZERO
	move_and_slide()
	if flame_breath_time >= flame_breath_duration:
		flame_breath_active = false
		_end_cast()


func _evaluate_custom_attacks(dist: float) -> void:
	if charge_timer >= charge_cooldown and dist < 120 and dist > 50:
		begin_chase_dash(&"charge_timer", charge_speed, charge_duration, charge_damage)
		return
	if flame_breath_timer >= flame_breath_cooldown and dist < 80:
		_cast_flame_breath()
		return
	if fireball_timer >= fireball_cooldown and dist < 160:
		_cast_fireball()
		return


func _cast_fireball() -> void:
	cast_single_attack(&"fireball_timer", fireball_speed, Color(1.0, 0.4, 0.1), Vector2(1.4, 1.4), spawn_marker)


func _cast_flame_breath() -> void:
	if not await _begin_cast(&"flame_breath_timer", 0.4):
		return
	flame_breath_active = true
	flame_breath_time = 0.0
	flame_breath_tick = 0.0
	play_animation("move")


func _apply_phase_scaling() -> void:
	super()
	_scale_attack_cooldown(&"fireball_cooldown", 0.8)
	_scale_attack_cooldown(&"flame_breath_cooldown", 2.5)
	_scale_attack_cooldown(&"charge_cooldown", 2.0)
	if current_phase >= 2:
		flame_breath_damage = 3
		charge_damage = 5
