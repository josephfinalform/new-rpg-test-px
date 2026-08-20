class_name CrystalGuardian
extends BossEnemy

enum SpecialAttack { SHARD, SUMMON, CHARGE }

@export_group("Crystal Guardian Attacks")
@export var shard_cooldown: float = 2.0
@export var charge_cooldown: float = 5.5
@export var shard_speed: float = 115.0
@export var shard_count: int = 3
@export var charge_speed: float = 240.0
@export var charge_duration: float = 0.55
@export var charge_damage: int = 2

var shard_timer: float = 0.0
var charge_timer: float = 0.0
var is_charging: bool = false
var charge_direction: Vector2 = Vector2.ZERO
var charge_time: float = 0.0
var charge_hit_cd: float = 0.0

@onready var spawn_marker: Marker2D = $SpawnMarker


func _ready() -> void:
	boss_name = "CRYSTAL GUARDIAN"
	max_health = 34
	xp_reward = 32
	bonus_xp_reward = 90
	attack_range = 26.0
	boss_tint = Color(0.5, 0.88, 1.0)
	base_sprite_scale = Vector2(2.2, 2.2)
	minion_scene = preload("res://aarpg/Enemies/crystal_slime.tscn")
	minion_tint = Color(0.5, 0.9, 1.0)
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
	if is_charging:
		_process_charge(delta)
		return
	shard_timer += delta
	summon_timer += delta
	charge_timer += delta
	if current_state == State.CHASE or current_state == State.ATTACK:
		_evaluate_special_attacks()
	super(delta)


func _process_charge(delta: float) -> void:
	process_dash(delta, charge_speed, charge_duration, charge_damage, &"charge_hit_cd", &"charge_time", &"is_charging", charge_direction)


func _evaluate_special_attacks() -> void:
	if not chase_target or not is_instance_valid(chase_target):
		return
	var dist = global_position.distance_to(chase_target.global_position)
	if current_phase >= 1 and summon_timer >= summon_cooldown and dist < 160:
		summon_minions()
		return
	if charge_timer >= charge_cooldown and dist < 110 and dist > 45:
		_start_charge()
		return
	if shard_timer >= shard_cooldown and dist < 160:
		_cast_shards()
		return


func _cast_shards() -> void:
	if not await _begin_cast(&"shard_timer", shard_cooldown):
		return
	shoot_fan_projectiles(shard_count, shard_speed, 14.0, Color(0.5, 0.9, 1.0), Vector2(1.2, 1.2), spawn_marker)
	_end_cast()


func _start_charge() -> void:
	if is_casting:
		return
	is_casting = true
	charge_timer = 0.0
	current_state = State.ATTACK
	play_animation("cast")
	await get_tree().create_timer(0.35).timeout
	if is_dead:
		is_casting = false
		return
	if chase_target and is_instance_valid(chase_target):
		charge_direction = (chase_target.global_position - global_position).normalized()
		is_charging = true
		charge_time = 0.0
		charge_hit_cd = 0.0
		play_animation("move")
		current_state = State.CHASE


func _play_phase_effect() -> void:
	super()
	if current_phase == 1:
		shard_cooldown = max(1.0, shard_cooldown * 0.8)
		charge_cooldown = max(3.0, charge_cooldown * 0.8)
	elif current_phase == 2:
		shard_cooldown = max(0.6, shard_cooldown * 0.7)
		charge_cooldown = max(2.0, charge_cooldown * 0.7)
		summon_cooldown = max(5.0, summon_cooldown * 0.8)


func _apply_phase_scaling() -> void:
	super()
	if current_phase >= 1:
		shard_count = 4
	if current_phase >= 2:
		shard_count = 5
		charge_damage = 3
