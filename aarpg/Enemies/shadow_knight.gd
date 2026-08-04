class_name ShadowKnight
extends BossEnemy

enum SpecialAttack { DASH, WHIRLWIND, SUMMON }

const BAT_SCENE = preload("res://aarpg/Enemies/bat.tscn")
const BOSS_NAME := "SHADOW KNIGHT"

@export_group("Knight Attacks")
@export var dash_cooldown: float = 3.5
@export var whirlwind_cooldown: float = 7.0
@export var summon_cooldown: float = 9.0
@export var dash_speed: float = 260.0
@export var dash_duration: float = 0.5
@export var dash_damage: int = 3
@export var whirlwind_damage: int = 2
@export var whirlwind_radius: float = 42.0
@export var minion_count: int = 2

var dash_timer: float = 0.0
var whirlwind_timer: float = 0.0
var summon_timer: float = 0.0
var is_casting: bool = false
var is_dashing: bool = false
var dash_direction: Vector2 = Vector2.ZERO
var dash_time: float = 0.0
var dash_hit_cd: float = 0.0
var is_whirlwinding: bool = false
var whirlwind_time: float = 0.0
var whirlwind_tick: float = 0.0
var base_sprite_scale: Vector2 = Vector2(1.9, 1.9)


func _ready() -> void:
	super()
	max_health = 34
	health = max_health
	move_speed = 55.0
	damage = 3
	xp_reward = 32
	bonus_xp_reward = 90
	attack_range = 30.0
	phase_health_thresholds = [0.66, 0.33]
	sprite.self_modulate = Color(0.28, 0.18, 0.5)
	sprite.scale = base_sprite_scale


func get_boss_name() -> String:
	return BOSS_NAME


func _physics_process(delta: float) -> void:
	if is_dead or is_transitioning:
		return
	if is_casting:
		velocity = Vector2.ZERO
		base_velocity = Vector2.ZERO
		move_and_slide()
		return
	if is_dashing:
		_process_dash(delta)
		return
	if is_whirlwinding:
		_process_whirlwind(delta)
		return
	dash_timer += delta
	whirlwind_timer += delta
	summon_timer += delta
	if current_state == State.CHASE or current_state == State.ATTACK:
		_evaluate_special_attacks()
	super(delta)


func _process_dash(delta: float) -> void:
	dash_time += delta
	dash_hit_cd = max(0.0, dash_hit_cd - delta)
	velocity = dash_direction * dash_speed
	move_and_slide()
	if dash_hit_cd <= 0.0 and chase_target and is_instance_valid(chase_target):
		if global_position.distance_to(chase_target.global_position) < 26.0:
			chase_target.take_damage(dash_damage, global_position)
			dash_hit_cd = 0.35
	if dash_time >= dash_duration:
		is_dashing = false
		play_animation("move")
		if chase_target and is_instance_valid(chase_target):
			current_state = State.CHASE
		else:
			current_state = State.IDLE


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


func _evaluate_special_attacks() -> void:
	if not chase_target or not is_instance_valid(chase_target):
		return
	var dist = global_position.distance_to(chase_target.global_position)
	if current_phase >= 1 and summon_timer >= summon_cooldown and dist < 180:
		_summon_shadows()
		return
	if whirlwind_timer >= whirlwind_cooldown and dist < 55:
		_start_whirlwind()
		return
	if dash_timer >= dash_cooldown and dist < 110 and dist > 45:
		_start_dash()
		return


func _start_dash() -> void:
	if is_casting:
		return
	is_casting = true
	dash_timer = 0.0
	current_state = State.ATTACK
	play_animation("cast")
	await get_tree().create_timer(0.25).timeout
	if is_dead:
		is_casting = false
		return
	if chase_target and is_instance_valid(chase_target):
		dash_direction = (chase_target.global_position - global_position).normalized()
		is_dashing = true
		dash_time = 0.0
		dash_hit_cd = 0.0
		play_animation("move")
		current_state = State.CHASE


func _start_whirlwind() -> void:
	if is_casting:
		return
	is_casting = true
	whirlwind_timer = 0.0
	current_state = State.ATTACK
	play_animation("cast")
	await get_tree().create_timer(0.3).timeout
	if is_dead:
		is_casting = false
		return
	is_whirlwinding = true
	whirlwind_time = 0.0
	whirlwind_tick = 0.0


func _summon_shadows() -> void:
	if is_casting:
		return
	is_casting = true
	summon_timer = 0.0
	current_state = State.ATTACK
	play_animation("cast")
	await get_tree().create_timer(0.5).timeout
	if is_dead:
		is_casting = false
		return
	for i in range(minion_count):
		var bat = BAT_SCENE.instantiate()
		var offset = Vector2(randf_range(-50, 50), randf_range(-50, 50))
		get_parent().add_child(bat)
		bat.global_position = global_position + offset
		bat.sprite.self_modulate = Color(0.28, 0.18, 0.5)
	play_animation("move")
	is_casting = false
	if chase_target and is_instance_valid(chase_target):
		current_state = State.CHASE
	else:
		current_state = State.IDLE


func _play_phase_effect() -> void:
	super()
	sprite.modulate = Color(0.6, 0.3, 0.9)
	var tween = create_tween()
	tween.tween_property(sprite, "scale", base_sprite_scale * 1.5, 0.25).set_trans(Tween.TRANS_ELASTIC)
	tween.tween_property(sprite, "scale", base_sprite_scale, 0.3).set_trans(Tween.TRANS_BACK)
	if current_phase == 1:
		dash_cooldown = max(2.0, dash_cooldown * 0.8)
		whirlwind_cooldown = max(5.0, whirlwind_cooldown * 0.8)
	elif current_phase == 2:
		dash_cooldown = max(1.2, dash_cooldown * 0.7)
		whirlwind_cooldown = max(3.5, whirlwind_cooldown * 0.75)
		summon_cooldown = max(5.0, summon_cooldown * 0.8)


func _apply_phase_scaling() -> void:
	super()
	if current_phase >= 1:
		minion_count = 2
	if current_phase >= 2:
		minion_count = 3
		whirlwind_damage = 3
