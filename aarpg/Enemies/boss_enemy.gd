class_name BossEnemy
extends Enemy

@export_group("Boss Settings")
@export var boss_name: String = "BOSS"
@export var phase_health_thresholds: Array[float] = [0.66, 0.33]
@export var phase_transition_time: float = 1.5
@export var enrage_speed_mult: float = 1.3
@export var enrage_damage_mult: float = 1.25
@export var enrage_cooldown_mult: float = 0.8
@export var bonus_xp_reward: int = 50
@export var boss_tint: Color = Color.WHITE
@export var base_sprite_scale: Vector2 = Vector2(1.0, 1.0)

@export_group("Minion Settings")
@export var minion_scene: PackedScene
@export var minion_count: int = 2
@export var minion_tint: Color = Color.WHITE
@export var minion_spawn_radius: float = 40.0

var attack_timers: Array[StringName] = []
var summon_timer: float = 0.0
@export var summon_cooldown: float = 9.0
@export var summon_phase_threshold: int = 1
@export var summon_distance_threshold: float = 160.0

var current_phase: int = 0
var max_phases: int = 1
var is_casting: bool = false

var dash_is_active: bool = false
var dash_direction: Vector2 = Vector2.ZERO
var dash_time: float = 0.0
var dash_hit_cd: float = 0.0
var active_dash_speed: float = 200.0
var active_dash_duration: float = 0.5
var active_dash_damage: int = 1
var active_dash_hit_range: float = 24.0
var active_dash_hit_cd_reset: float = 0.4

@onready var boss_health_bar: ProgressBar = $BossHealthBar
@onready var hp_tween: Tween


func _ready() -> void:
	super()
	max_phases = phase_health_thresholds.size() + 1
	if boss_health_bar:
		boss_health_bar.max_value = max_health
		boss_health_bar.value = health
		boss_health_bar.modulate = boss_tint
	sprite.scale = base_sprite_scale


func _apply_data(data: EnemyData) -> void:
	super(data)
	boss_tint = data.tint
	base_sprite_scale = data.sprite_scale
	var boss_data := data as BossData
	if boss_data == null:
		return
	boss_name = boss_data.boss_name
	bonus_xp_reward = boss_data.bonus_xp_reward
	minion_scene = boss_data.minion_scene
	minion_tint = boss_data.minion_tint
	minion_spawn_radius = boss_data.minion_spawn_radius
	summon_phase_threshold = boss_data.summon_phase_threshold
	summon_distance_threshold = boss_data.summon_distance_threshold


func _physics_process(delta: float) -> void:
	if is_dead or is_transitioning:
		return
	if is_casting:
		velocity = Vector2.ZERO
		base_velocity = Vector2.ZERO
		move_and_slide()
		return
	if _is_special_active():
		_process_special(delta)
		return
	summon_timer += delta
	_update_attack_timers(delta)
	if current_state == State.CHASE or current_state == State.ATTACK:
		_evaluate_special_attacks()
	super(delta)


func _is_special_active() -> bool:
	return dash_is_active


func _process_special(delta: float) -> void:
	if dash_is_active:
		process_dash(delta, active_dash_speed, active_dash_duration, active_dash_damage, dash_direction, active_dash_hit_range, active_dash_hit_cd_reset)


func _update_attack_timers(delta: float) -> void:
	for timer_ref in attack_timers:
		set(timer_ref, float(get(timer_ref)) + delta)


func _evaluate_special_attacks() -> void:
	if not has_valid_target():
		return
	var dist := global_position.distance_to(chase_target.global_position)
	if current_phase >= summon_phase_threshold and summon_timer >= summon_cooldown and dist < summon_distance_threshold:
		summon_minions()
		return
	_evaluate_custom_attacks(dist)


func _evaluate_custom_attacks(_dist: float) -> void:
	pass


func get_boss_name() -> String:
	return boss_name


func take_damage(amount: int, from_position: Vector2, attacker: Node2D = null) -> void:
	super(amount, from_position, attacker)
	if boss_health_bar:
		if hp_tween and hp_tween.is_valid():
			hp_tween.kill()
		hp_tween = create_tween()
		hp_tween.tween_property(boss_health_bar, "value", health, 0.15)
	if not is_dead:
		_check_phase_transition()


func _check_phase_transition() -> void:
	if is_transitioning or is_dead:
		return
	var health_ratio: float = float(health) / maxf(float(max_health), 1.0)
	if current_phase < phase_health_thresholds.size() and health_ratio <= phase_health_thresholds[current_phase]:
		current_phase += 1
		_start_phase_transition()


func _start_phase_transition() -> void:
	is_transitioning = true
	is_invincible = true
	current_state = State.HURT
	_play_phase_effect()
	await get_tree().create_timer(phase_transition_time).timeout
	_apply_phase_scaling()
	is_transitioning = false
	is_invincible = false
	sprite.modulate = Color.WHITE
	_resume_chase_or_idle()


func _play_phase_effect() -> void:
	sprite.modulate = boss_tint
	var tween = create_tween()
	tween.tween_property(sprite, "scale", base_sprite_scale * 1.5, 0.25).set_trans(Tween.TRANS_ELASTIC)
	tween.tween_property(sprite, "scale", base_sprite_scale, 0.3).set_trans(Tween.TRANS_BACK)
	if boss_health_bar:
		boss_health_bar.modulate = Color.RED
		await get_tree().create_timer(0.3).timeout
		boss_health_bar.modulate = Color.WHITE


const PHASE_COOLDOWN_MULT_1 := 0.8
const PHASE_COOLDOWN_MULT_2 := 0.7


func _apply_phase_scaling() -> void:
	move_speed *= 1.0 + (enrage_speed_mult - 1.0) * float(current_phase) / float(max_phases)
	var dmg_mult: float = 1.0 + (enrage_damage_mult - 1.0) * float(current_phase) / float(max_phases)
	damage = ceili(float(damage) * dmg_mult)
	var cd_mult: float = 1.0 - (1.0 - enrage_cooldown_mult) * float(current_phase) / float(max_phases)
	attack_cooldown_time = max(0.15, attack_cooldown_time * cd_mult)
	_scale_attack_cooldown(&"summon_cooldown", 5.0)
	if current_phase >= 1:
		minion_count = 2
	if current_phase >= 2:
		minion_count = 3


func _scale_attack_cooldown(cooldown_ref: StringName, min_value: float) -> void:
	var mult := PHASE_COOLDOWN_MULT_1 if current_phase <= 1 else PHASE_COOLDOWN_MULT_2
	set(cooldown_ref, maxf(min_value, float(get(cooldown_ref)) * mult))


func _die() -> void:
	if boss_health_bar:
		boss_health_bar.hide()
	super()
	_grant_player_xp(bonus_xp_reward)


func _play_death_effect() -> void:
	var tween = create_tween()
	tween.set_parallel(true)
	tween.tween_property(sprite, "modulate:a", 0.0, 0.5)
	tween.tween_property(sprite, "scale", Vector2(2.0, 2.0), 0.4).set_trans(Tween.TRANS_ELASTIC)
	tween.chain().tween_property(sprite, "scale", Vector2(0.0, 0.0), 0.2)
	tween.tween_callback(queue_free)


func _level_scaling_multipliers() -> Vector3:
	return Vector3(0.12, 0.1, 0.1)


func apply_level_scaling(level_index: int) -> void:
	super(level_index)
	if boss_health_bar:
		boss_health_bar.max_value = max_health
		boss_health_bar.value = health


func _begin_cast(timer_ref: StringName, windup_time: float = 0.3, anim: String = "cast") -> bool:
	if is_casting:
		return false
	is_casting = true
	set(timer_ref, 0.0)
	current_state = State.ATTACK
	play_animation(anim)
	await get_tree().create_timer(windup_time).timeout
	if is_dead:
		is_casting = false
		return false
	return true


func _resume_chase_or_idle() -> void:
	if has_valid_target():
		current_state = State.CHASE
	else:
		current_state = State.IDLE


func _end_cast() -> void:
	play_animation("move")
	is_casting = false
	_resume_chase_or_idle()


func cast_fan_attack(timer_ref: StringName, count: int, speed: float, spread_deg: float, tint: Color, proj_scale: Vector2 = Vector2.ONE, from_marker: Marker2D = null, windup_time: float = 0.3) -> bool:
	if not await _begin_cast(timer_ref, windup_time):
		return false
	shoot_fan_projectiles(count, speed, spread_deg, tint, proj_scale, from_marker)
	_end_cast()
	return true


func cast_single_attack(timer_ref: StringName, speed: float, tint: Color, proj_scale: Vector2 = Vector2.ONE, from_marker: Marker2D = null, windup_time: float = 0.3) -> bool:
	if not await _begin_cast(timer_ref, windup_time):
		return false
	if has_valid_target():
		var dir = (chase_target.global_position - global_position).normalized()
		spawn_projectile(dir, speed, tint, proj_scale, from_marker)
	_end_cast()
	return true


func summon_minions() -> void:
	if not await _begin_cast(&"summon_timer", 0.5):
		return
	if minion_scene:
		for i in range(minion_count):
			var minion = minion_scene.instantiate()
			var offset = Vector2(randf_range(-minion_spawn_radius, minion_spawn_radius), randf_range(-minion_spawn_radius, minion_spawn_radius))
			get_parent().add_child(minion)
			minion.global_position = global_position + offset
			if minion.get("sprite") and minion_tint != Color.WHITE:
				minion.sprite.self_modulate = minion_tint
	_end_cast()


func process_dash(delta: float, speed: float, duration: float, dmg: int, dir: Vector2, hit_range: float = 24.0, hit_cd_reset: float = 0.4) -> void:
	dash_time += delta
	dash_hit_cd = maxf(dash_hit_cd - delta, 0.0)
	velocity = dir * speed
	move_and_slide()
	if dash_hit_cd <= 0.0 and has_valid_target():
		if global_position.distance_to(chase_target.global_position) < hit_range:
			chase_target.take_damage(dmg, global_position)
			dash_hit_cd = hit_cd_reset
	if dash_time >= duration:
		dash_is_active = false
		play_animation("move")
		_resume_chase_or_idle()


func shoot_fan_projectiles(count: int, speed: float, spread_deg: float, tint: Color, proj_scale: Vector2 = Vector2.ONE, from_marker: Marker2D = null) -> void:
	if not has_valid_target():
		return
	var dir: Vector2 = (chase_target.global_position - global_position).normalized()
	var base_angle := dir.angle()
	for i in range(count):
		var angle := base_angle + deg_to_rad((i - (count - 1) / 2.0) * spread_deg)
		spawn_projectile(Vector2.from_angle(angle), speed, tint, proj_scale, from_marker)


func start_dash(attack_timer_ref: StringName, speed: float, duration: float, damage: int, attack_anim: String = "cast", hit_range: float = 24.0, hit_cd_reset: float = 0.4) -> bool:
	if not await _begin_cast(attack_timer_ref, 0.3, attack_anim):
		return false
	if has_valid_target():
		dash_is_active = true
		dash_time = 0.0
		dash_hit_cd = 0.0
		active_dash_speed = speed
		active_dash_duration = duration
		active_dash_damage = damage
		active_dash_hit_range = hit_range
		active_dash_hit_cd_reset = hit_cd_reset
		play_animation("move")
		current_state = State.CHASE
	return true


func begin_chase_dash(attack_timer_ref: StringName, speed: float, duration: float, dmg: int, attack_anim: String = "cast", hit_range: float = 24.0, hit_cd_reset: float = 0.4) -> void:
	if await start_dash(attack_timer_ref, speed, duration, dmg, attack_anim, hit_range, hit_cd_reset):
		if has_valid_target():
			dash_direction = (chase_target.global_position - global_position).normalized()
