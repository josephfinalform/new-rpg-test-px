class_name BossEnemy
extends Enemy

const PROJECTILE_SCENE = preload("res://aarpg/Enemies/boss_projectile.tscn")

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

var summon_timer: float = 0.0
@export var summon_cooldown: float = 9.0

var current_phase: int = 0
var max_phases: int = 1
var is_transitioning: bool = false
var is_casting: bool = false

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


func _physics_process(delta: float) -> void:
	if is_dead or is_transitioning:
		return
	if is_casting:
		velocity = Vector2.ZERO
		base_velocity = Vector2.ZERO
		move_and_slide()
		return
	summon_timer += delta
	if current_state == State.CHASE or current_state == State.ATTACK:
		_evaluate_special_attacks()
	super(delta)


func _evaluate_special_attacks() -> void:
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
	var health_ratio: float = float(health) / float(max_health)
	while current_phase < phase_health_thresholds.size() and health_ratio <= phase_health_thresholds[current_phase]:
		current_phase += 1
		_start_phase_transition()
		return


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
	if chase_target and is_instance_valid(chase_target):
		current_state = State.CHASE
	else:
		current_state = State.IDLE


func _play_phase_effect() -> void:
	sprite.modulate = boss_tint
	var tween = create_tween()
	tween.tween_property(sprite, "scale", base_sprite_scale * 1.5, 0.25).set_trans(Tween.TRANS_ELASTIC)
	tween.tween_property(sprite, "scale", base_sprite_scale, 0.3).set_trans(Tween.TRANS_BACK)
	if boss_health_bar:
		boss_health_bar.modulate = Color.RED
		await get_tree().create_timer(0.3).timeout
		boss_health_bar.modulate = Color.WHITE


func _apply_phase_scaling() -> void:
	move_speed *= 1.0 + (enrage_speed_mult - 1.0) * float(current_phase) / float(max_phases)
	var dmg_mult: float = 1.0 + (enrage_damage_mult - 1.0) * float(current_phase) / float(max_phases)
	damage = ceili(float(damage) * dmg_mult)
	var cd_mult: float = 1.0 - (1.0 - enrage_cooldown_mult) * float(current_phase) / float(max_phases)
	attack_cooldown_time = max(0.15, attack_cooldown_time * cd_mult)
	if current_phase >= 2:
		summon_cooldown = maxf(5.0, summon_cooldown * PHASE_COOLDOWN_MULT_1)
	if current_phase >= 1:
		minion_count = 2
	if current_phase >= 2:
		minion_count = 3


const PHASE_COOLDOWN_MULT_1 := 0.8
const PHASE_COOLDOWN_MULT_2 := 0.7


func _scale_attack_cooldown(cooldown_ref: StringName, min_value: float) -> void:
	var mult := PHASE_COOLDOWN_MULT_1 if current_phase <= 1 else PHASE_COOLDOWN_MULT_2
	set(cooldown_ref, maxf(min_value, float(get(cooldown_ref)) * mult))


func _die() -> void:
	if boss_health_bar:
		boss_health_bar.hide()
	super()
	if _cached_player and not _cached_player.is_dead:
		_cached_player.gain_xp(bonus_xp_reward)


func _play_death_effect() -> void:
	var tween = create_tween()
	tween.set_parallel(true)
	tween.tween_property(sprite, "modulate:a", 0.0, 0.5)
	tween.tween_property(sprite, "scale", Vector2(2.0, 2.0), 0.4).set_trans(Tween.TRANS_ELASTIC)
	tween.chain().tween_property(sprite, "scale", Vector2(0.0, 0.0), 0.2)
	tween.tween_callback(queue_free)


func _process_hurt(_delta: float) -> void:
	if hurt_timer.is_stopped() and not is_transitioning:
		if is_dead:
			return
		if chase_target and is_instance_valid(chase_target):
			current_state = State.CHASE
		else:
			current_state = State.IDLE


func apply_level_scaling(level_index: int) -> void:
	if is_dead or level_index <= 0:
		return
	var hp_mult := 1.0 + 0.12 * float(level_index)
	var dmg_mult := 1.0 + 0.1 * float(level_index)
	var xp_mult := 1.0 + 0.1 * float(level_index)
	max_health = ceili(float(max_health) * hp_mult)
	health = max_health
	damage = ceili(float(damage) * dmg_mult)
	xp_reward = roundi(float(xp_reward) * xp_mult)
	if boss_health_bar:
		boss_health_bar.max_value = max_health
		boss_health_bar.value = health


func _begin_cast(timer_ref: StringName, windup_time: float = 0.3) -> bool:
	if is_casting:
		return false
	is_casting = true
	set(timer_ref, 0.0)
	current_state = State.ATTACK
	play_animation("cast")
	await get_tree().create_timer(windup_time).timeout
	if is_dead:
		is_casting = false
		return false
	return true


func _end_cast() -> void:
	play_animation("move")
	is_casting = false
	if chase_target and is_instance_valid(chase_target):
		current_state = State.CHASE
	else:
		current_state = State.IDLE


func summon_minions() -> void:
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
	if minion_scene:
		for i in range(minion_count):
			var minion = minion_scene.instantiate()
			var offset = Vector2(randf_range(-minion_spawn_radius, minion_spawn_radius), randf_range(-minion_spawn_radius, minion_spawn_radius))
			get_parent().add_child(minion)
			minion.global_position = global_position + offset
			if minion.get("sprite") and minion_tint != Color.WHITE:
				minion.sprite.self_modulate = minion_tint
	_end_cast()


func process_dash(delta: float, speed: float, duration: float, dmg: int, hit_cd_ref: StringName, time_ref: StringName, active_ref: StringName, dir: Vector2, hit_range: float = 24.0, hit_cd_reset: float = 0.4) -> void:
	set(time_ref, get(time_ref) + delta)
	var current_hit_cd: float = get(hit_cd_ref)
	current_hit_cd = maxf(current_hit_cd - delta)
	set(hit_cd_ref, current_hit_cd)
	velocity = dir * speed
	move_and_slide()
	if current_hit_cd <= 0.0 and chase_target and is_instance_valid(chase_target):
		if global_position.distance_to(chase_target.global_position) < hit_range:
			chase_target.take_damage(dmg, global_position)
			set(hit_cd_ref, hit_cd_reset)
	if get(time_ref) >= duration:
		set(active_ref, false)
		play_animation("move")
		if chase_target and is_instance_valid(chase_target):
			current_state = State.CHASE
		else:
			current_state = State.IDLE


func shoot_fan_projectiles(count: int, speed: float, spread_deg: float, tint: Color, proj_scale: Vector2 = Vector2.ONE, from_marker: Marker2D = null) -> void:
	if not chase_target or not is_instance_valid(chase_target):
		return
	var dir: Vector2 = (chase_target.global_position - global_position).normalized()
	var base_angle := dir.angle()
	for i in range(count):
		var angle := base_angle + deg_to_rad((i - (count - 1) / 2.0) * spread_deg)
		var projectile := PROJECTILE_SCENE.instantiate()
		projectile.global_position = from_marker.global_position if from_marker else global_position
		projectile.direction = Vector2.from_angle(angle)
		projectile.speed = speed
		projectile.damage = damage
		projectile.projectile_tint = tint
		projectile.scale = proj_scale
		get_parent().add_child(projectile)


func start_dash(attack_timer_ref: StringName, speed: float, duration: float, damage: int, hit_cd_ref: StringName, time_ref: StringName, active_ref: StringName, attack_anim: String = "cast") -> bool:
	if is_casting:
		return false
	is_casting = true
	set(attack_timer_ref, 0.0)
	current_state = State.ATTACK
	play_animation(attack_anim)
	await get_tree().create_timer(0.3).timeout
	if is_dead:
		is_casting = false
		return false
	if chase_target and is_instance_valid(chase_target):
		set(active_ref, true)
		set(time_ref, 0.0)
		set(hit_cd_ref, 0.0)
		play_animation("move")
		current_state = State.CHASE
	return true


func begin_chase_dash(direction_ref: StringName, attack_timer_ref: StringName, speed: float, duration: float, dmg: int, hit_cd_ref: StringName, time_ref: StringName, active_ref: StringName, attack_anim: String = "cast") -> void:
	if await start_dash(attack_timer_ref, speed, duration, dmg, hit_cd_ref, time_ref, active_ref, attack_anim):
		if chase_target and is_instance_valid(chase_target):
			set(direction_ref, (chase_target.global_position - global_position).normalized())
