class_name ShadowKnight
extends BossEnemy

@export_group("Knight Attacks")
@export var dash_cooldown: float = 3.5
@export var whirlwind_cooldown: float = 7.0
@export var dash_speed: float = 260.0
@export var dash_duration: float = 0.5
@export var dash_damage: int = 3
@export var whirlwind_damage: int = 2
@export var whirlwind_radius: float = 42.0

var dash_timer: float = 0.0
var whirlwind_timer: float = 0.0
var is_whirlwinding: bool = false
var whirlwind_time: float = 0.0
var whirlwind_tick: float = 0.0

const DATA = preload("res://aarpg/config/enemies/shadow_knight_data.tres")


func _ready() -> void:
	enemy_data = DATA
	super()


func _is_special_active() -> bool:
	return dash_is_active or is_whirlwinding

func _process_special(delta: float) -> void:
	if dash_is_active:
		process_dash(delta, dash_speed, dash_duration, dash_damage, dash_direction, 26.0, 0.35)
	elif is_whirlwinding:
		_process_whirlwind(delta)

func _update_attack_timers(delta: float) -> void:
	dash_timer += delta
	whirlwind_timer += delta


func _process_whirlwind(delta: float) -> void:
	whirlwind_time += delta
	whirlwind_tick = max(0.0, whirlwind_tick - delta)
	sprite.rotation += delta * 16.0
	var dir: Vector2 = Vector2.ZERO
	if chase_target and is_instance_valid(chase_target):
		dir = (chase_target.global_position - global_position).normalized()
		if whirlwind_tick <= 0.0 and global_position.distance_to(chase_target.global_position) < whirlwind_radius:
			chase_target.take_damage(whirlwind_damage, global_position)
			whirlwind_tick = 0.5
	velocity = dir * move_speed * 0.6
	move_and_slide()
	if whirlwind_time >= 2.0:
		is_whirlwinding = false
		sprite.rotation = 0.0
		play_animation("move")
		if chase_target and is_instance_valid(chase_target):
			current_state = State.CHASE
		else:
			current_state = State.IDLE


func _evaluate_custom_attacks(dist: float) -> void:
	if whirlwind_timer >= whirlwind_cooldown and dist < 55:
		_start_whirlwind()
		return
	if dash_timer >= dash_cooldown and dist < 110 and dist > 45:
		begin_chase_dash(&"dash_timer", dash_speed, dash_duration, dash_damage)
		return


func _start_whirlwind() -> void:
	if not await _begin_cast(&"whirlwind_timer"):
		return
	is_whirlwinding = true
	whirlwind_time = 0.0
	whirlwind_tick = 0.0


func _apply_phase_scaling() -> void:
	super()
	_scale_attack_cooldown(&"dash_cooldown", 1.2)
	_scale_attack_cooldown(&"whirlwind_cooldown", 3.5)
	if current_phase >= 2:
		whirlwind_damage = 3
