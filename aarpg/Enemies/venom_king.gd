class_name VenomKing
extends BossEnemy

enum SpecialAttack { SPIT, SUMMON, DASH }

@export_group("Venom King Attacks")
@export var spit_cooldown: float = 2.2
@export var dash_cooldown: float = 5.0
@export var spit_speed: float = 105.0
@export var spit_count: int = 3
@export var dash_speed: float = 230.0
@export var dash_duration: float = 0.5
@export var dash_damage: int = 2

var spit_timer: float = 0.0
var dash_timer: float = 0.0
var is_dashing: bool = false
var dash_direction: Vector2 = Vector2.ZERO
var dash_time: float = 0.0
var dash_hit_cd: float = 0.0

@onready var spawn_marker: Marker2D = $SpawnMarker


func _ready() -> void:
	boss_name = "VENOM KING"
	max_health = 30
	xp_reward = 30
	bonus_xp_reward = 80
	attack_range = 26.0
	boss_tint = Color(0.4, 0.75, 0.35)
	base_sprite_scale = Vector2(2.0, 2.0)
	minion_scene = preload("res://aarpg/Enemies/venom_slime.tscn")
	minion_tint = Color(0.45, 0.8, 0.4)
	sprite.self_modulate = boss_tint
	sprite.scale = base_sprite_scale
	if boss_health_bar:
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
	if is_dashing:
		process_dash(delta, dash_speed, dash_duration, dash_damage, &"dash_hit_cd", &"dash_time", &"is_dashing", dash_direction)
		return
	spit_timer += delta
	summon_timer += delta
	dash_timer += delta
	if current_state == State.CHASE or current_state == State.ATTACK:
		_evaluate_special_attacks()
	super(delta)


func _evaluate_special_attacks() -> void:
	if not chase_target or not is_instance_valid(chase_target):
		return
	var dist = global_position.distance_to(chase_target.global_position)
	if current_phase >= 1 and summon_timer >= summon_cooldown and dist < 160:
		summon_minions()
		return
	if dash_timer >= dash_cooldown and dist < 110 and dist > 45:
		_start_dash()
		return
	if spit_timer >= spit_cooldown and dist < 150:
		_cast_spit()
		return


func _cast_spit() -> void:
	if not await _begin_cast(&"spit_timer", spit_cooldown):
		return
	shoot_fan_projectiles(spit_count, spit_speed, 12.0, Color(0.45, 0.85, 0.4), Vector2(1.1, 1.1), spawn_marker)
	_end_cast()


func _start_dash() -> void:
	if is_casting:
		return
	is_casting = true
	dash_timer = 0.0
	current_state = State.ATTACK
	play_animation("cast")
	await get_tree().create_timer(0.35).timeout
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


func _play_phase_effect() -> void:
	super()
	if current_phase == 1:
		spit_cooldown = max(1.0, spit_cooldown * 0.8)
		dash_cooldown = max(3.0, dash_cooldown * 0.8)
	elif current_phase == 2:
		spit_cooldown = max(0.6, spit_cooldown * 0.7)
		dash_cooldown = max(2.0, dash_cooldown * 0.7)
		summon_cooldown = max(5.0, summon_cooldown * 0.8)


func _apply_phase_scaling() -> void:
	super()
	if current_phase >= 1:
		spit_count = 4
	if current_phase >= 2:
		spit_count = 5
		dash_damage = 3
