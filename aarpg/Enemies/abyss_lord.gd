class_name AbyssLord
extends BossEnemy

enum SpecialAttack { VOID_BEAM, SHADOW_STEP, SUMMON }

const PROJECTILE_SCENE = preload("res://aarpg/Enemies/boss_projectile.tscn")
const WRAITH_SCENE = preload("res://aarpg/Enemies/abyssal_wraith.tscn")
const BOSS_NAME := "ABYSS LORD"

@export_group("Abyss Lord Attacks")
@export var beam_cooldown: float = 2.5
@export var step_cooldown: float = 4.0
@export var summon_cooldown: float = 10.0
@export var beam_speed: float = 120.0
@export var beam_count: int = 5
@export var step_speed: float = 280.0
@export var step_duration: float = 0.4
@export var step_damage: int = 3
@export var minion_count: int = 2

var beam_timer: float = 0.0
var step_timer: float = 0.0
var summon_timer: float = 0.0
var is_casting: bool = false
var is_stepping: bool = false
var step_direction: Vector2 = Vector2.ZERO
var step_time: float = 0.0
var step_hit_cd: float = 0.0
var base_sprite_scale: Vector2 = Vector2(2.2, 2.2)


func _ready() -> void:
	super()
	max_health = 38
	health = max_health
	move_speed = 42.0
	damage = 3
	xp_reward = 36
	bonus_xp_reward = 110
	attack_range = 28.0
	phase_health_thresholds = [0.66, 0.33]
	sprite.self_modulate = Color(0.55, 0.1, 0.7)
	sprite.scale = base_sprite_scale
	if boss_health_bar:
		boss_health_bar.max_value = max_health
		boss_health_bar.value = health
		boss_health_bar.modulate = Color(0.55, 0.1, 0.7)


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
	if is_stepping:
		_process_step(delta)
		return
	beam_timer += delta
	step_timer += delta
	summon_timer += delta
	if current_state == State.CHASE or current_state == State.ATTACK:
		_evaluate_special_attacks()
	super(delta)


func _process_step(delta: float) -> void:
	step_time += delta
	step_hit_cd = max(0.0, step_hit_cd - delta)
	velocity = step_direction * step_speed
	move_and_slide()
	if step_hit_cd <= 0.0 and chase_target and is_instance_valid(chase_target):
		if global_position.distance_to(chase_target.global_position) < 26.0:
			chase_target.take_damage(step_damage, global_position)
			step_hit_cd = 0.35
	if step_time >= step_duration:
		is_stepping = false
		play_animation("move")
		if chase_target and is_instance_valid(chase_target):
			current_state = State.CHASE
		else:
			current_state = State.IDLE


func _evaluate_special_attacks() -> void:
	if not chase_target or not is_instance_valid(chase_target):
		return
	var dist = global_position.distance_to(chase_target.global_position)
	if current_phase >= 1 and summon_timer >= summon_cooldown and dist < 170:
		_summon_wraiths()
		return
	if step_timer >= step_cooldown and dist < 120 and dist > 40:
		_start_shadow_step()
		return
	if beam_timer >= beam_cooldown and dist < 160:
		_cast_void_beam()
		return


func _cast_void_beam() -> void:
	if is_casting:
		return
	is_casting = true
	beam_timer = 0.0
	current_state = State.ATTACK
	play_animation("cast")
	await get_tree().create_timer(0.3).timeout
	if is_dead:
		is_casting = false
		return
	if chase_target and is_instance_valid(chase_target):
		var dir: Vector2 = (chase_target.global_position - global_position).normalized()
		var base_angle := dir.angle()
		for i in range(beam_count):
			var angle := base_angle + deg_to_rad((i - (beam_count - 1) / 2.0) * 12.0)
			var projectile := PROJECTILE_SCENE.instantiate()
			projectile.global_position = global_position
			projectile.direction = Vector2.from_angle(angle)
			projectile.speed = beam_speed
			projectile.damage = damage
			projectile.projectile_tint = Color(0.55, 0.1, 0.7)
			projectile.scale = Vector2(1.3, 1.3)
			get_parent().add_child(projectile)
	play_animation("move")
	is_casting = false
	if chase_target and is_instance_valid(chase_target):
		current_state = State.CHASE
	else:
		current_state = State.IDLE


func _start_shadow_step() -> void:
	if is_casting:
		return
	is_casting = true
	step_timer = 0.0
	current_state = State.ATTACK
	play_animation("cast")
	await get_tree().create_timer(0.25).timeout
	if is_dead:
		is_casting = false
		return
	if chase_target and is_instance_valid(chase_target):
		step_direction = (chase_target.global_position - global_position).normalized()
		is_stepping = true
		step_time = 0.0
		step_hit_cd = 0.0
		play_animation("move")
		current_state = State.CHASE


func _summon_wraiths() -> void:
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
		var wraith = WRAITH_SCENE.instantiate()
		var offset = Vector2(randf_range(-45, 45), randf_range(-45, 45))
		get_parent().add_child(wraith)
		wraith.global_position = global_position + offset
		wraith.sprite.self_modulate = Color(0.55, 0.1, 0.7)
	play_animation("move")
	is_casting = false
	if chase_target and is_instance_valid(chase_target):
		current_state = State.CHASE
	else:
		current_state = State.IDLE


func _play_phase_effect() -> void:
	super()
	sprite.modulate = Color(0.8, 0.2, 1.0)
	var tween = create_tween()
	tween.tween_property(sprite, "scale", base_sprite_scale * 1.5, 0.25).set_trans(Tween.TRANS_ELASTIC)
	tween.tween_property(sprite, "scale", base_sprite_scale, 0.3).set_trans(Tween.TRANS_BACK)
	if current_phase == 1:
		beam_cooldown = max(1.2, beam_cooldown * 0.8)
		step_cooldown = max(2.5, step_cooldown * 0.8)
	elif current_phase == 2:
		beam_cooldown = max(0.7, beam_cooldown * 0.7)
		step_cooldown = max(1.5, step_cooldown * 0.7)
		summon_cooldown = max(5.0, summon_cooldown * 0.8)


func _apply_phase_scaling() -> void:
	super()
	if current_phase >= 1:
		minion_count = 2
		beam_count = 6
	if current_phase >= 2:
		minion_count = 3
		beam_count = 7
		step_damage = 4
