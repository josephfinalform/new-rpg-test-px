class_name AbyssLord
extends BossEnemy

enum SpecialAttack { VOID_BEAM, SHADOW_STEP, SUMMON }

@export_group("Abyss Lord Attacks")
@export var beam_cooldown: float = 2.5
@export var step_cooldown: float = 4.0
@export var beam_speed: float = 120.0
@export var beam_count: int = 5
@export var step_speed: float = 280.0
@export var step_duration: float = 0.4
@export var step_damage: int = 3

var beam_timer: float = 0.0
var step_timer: float = 0.0
var is_stepping: bool = false
var step_direction: Vector2 = Vector2.ZERO
var step_time: float = 0.0
var step_hit_cd: float = 0.0


func _ready() -> void:
	boss_name = "ABYSS LORD"
	max_health = 38
	xp_reward = 36
	bonus_xp_reward = 110
	attack_range = 28.0
	boss_tint = Color(0.55, 0.1, 0.7)
	base_sprite_scale = Vector2(2.2, 2.2)
	minion_scene = preload("res://aarpg/Enemies/abyssal_wraith.tscn")
	minion_tint = Color(0.55, 0.1, 0.7)
	minion_spawn_radius = 45.0
	sprite.self_modulate = boss_tint
	sprite.scale = base_sprite_scale
	if boss_health_bar:
		boss_health_bar.max_value = max_health
		boss_health_bar.value = health
		boss_health_bar.modulate = boss_tint
	super()


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
	process_dash(delta, step_speed, step_duration, step_damage, &"step_hit_cd", &"step_time", &"is_stepping", step_direction, 26.0, 0.35)


func _evaluate_special_attacks() -> void:
	if not chase_target or not is_instance_valid(chase_target):
		return
	var dist = global_position.distance_to(chase_target.global_position)
	if current_phase >= 1 and summon_timer >= summon_cooldown and dist < 170:
		summon_minions()
		return
	if step_timer >= step_cooldown and dist < 120 and dist > 40:
		_start_shadow_step()
		return
	if beam_timer >= beam_cooldown and dist < 160:
		_cast_void_beam()
		return


func _cast_void_beam() -> void:
	if not await _begin_cast(&"beam_timer", beam_cooldown):
		return
	shoot_fan_projectiles(beam_count, beam_speed, 12.0, Color(0.55, 0.1, 0.7), Vector2(1.3, 1.3))
	_end_cast()


func _start_shadow_step() -> void:
	if await start_dash(&"step_timer", step_speed, step_duration, step_damage, &"step_hit_cd", &"step_time", &"is_stepping"):
		step_direction = (chase_target.global_position - global_position).normalized()


func _play_phase_effect() -> void:
	super()
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
		beam_count = 6
	if current_phase >= 2:
		beam_count = 7
		step_damage = 4
