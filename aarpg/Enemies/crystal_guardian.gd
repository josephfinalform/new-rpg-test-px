class_name CrystalGuardian
extends BossEnemy

enum SpecialAttack { SHARD, SUMMON, CHARGE }

const PROJECTILE_SCENE = preload("res://aarpg/Enemies/boss_projectile.tscn")
const MINION_SCENE = preload("res://aarpg/Enemies/crystal_slime.tscn")
const BOSS_NAME := "CRYSTAL GUARDIAN"

@export_group("Crystal Guardian Attacks")
@export var shard_cooldown: float = 2.0
@export var summon_cooldown: float = 10.0
@export var charge_cooldown: float = 5.5
@export var shard_speed: float = 115.0
@export var shard_count: int = 3
@export var charge_speed: float = 240.0
@export var charge_duration: float = 0.55
@export var charge_damage: int = 2
@export var minion_count: int = 2

var shard_timer: float = 0.0
var summon_timer: float = 0.0
var charge_timer: float = 0.0
var is_casting: bool = false
var is_charging: bool = false
var charge_direction: Vector2 = Vector2.ZERO
var charge_time: float = 0.0
var charge_hit_cd: float = 0.0
var base_sprite_scale: Vector2 = Vector2(2.2, 2.2)

@onready var spawn_marker: Marker2D = $SpawnMarker


func _ready() -> void:
	super()
	max_health = 34
	health = max_health
	move_speed = 40.0
	damage = 2
	xp_reward = 32
	bonus_xp_reward = 90
	attack_range = 26.0
	phase_health_thresholds = [0.66, 0.33]
	sprite.self_modulate = Color(0.5, 0.88, 1.0)
	sprite.scale = base_sprite_scale
	if boss_health_bar:
		boss_health_bar.max_value = max_health
		boss_health_bar.value = health
		boss_health_bar.modulate = Color(0.5, 0.88, 1.0)


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
	charge_time += delta
	charge_hit_cd = max(0.0, charge_hit_cd - delta)
	velocity = charge_direction * charge_speed
	move_and_slide()
	if charge_hit_cd <= 0.0 and chase_target and is_instance_valid(chase_target):
		if global_position.distance_to(chase_target.global_position) < 24.0:
			chase_target.take_damage(charge_damage, global_position)
			charge_hit_cd = 0.4
	if charge_time >= charge_duration:
		is_charging = false
		play_animation("move")
		if chase_target and is_instance_valid(chase_target):
			current_state = State.CHASE
		else:
			current_state = State.IDLE


func _evaluate_special_attacks() -> void:
	if not chase_target or not is_instance_valid(chase_target):
		return
	var dist = global_position.distance_to(chase_target.global_position)
	if current_phase >= 1 and summon_timer >= summon_cooldown and dist < 160:
		_summon_minions()
		return
	if charge_timer >= charge_cooldown and dist < 110 and dist > 45:
		_start_charge()
		return
	if shard_timer >= shard_cooldown and dist < 160:
		_cast_shards()
		return


func _cast_shards() -> void:
	if is_casting:
		return
	is_casting = true
	shard_timer = 0.0
	current_state = State.ATTACK
	play_animation("cast")
	await get_tree().create_timer(0.3).timeout
	if is_dead:
		is_casting = false
		return
	if chase_target and is_instance_valid(chase_target):
		var dir: Vector2 = (chase_target.global_position - global_position).normalized()
		var base_angle := dir.angle()
		for i in range(shard_count):
			var angle := base_angle + deg_to_rad((i - (shard_count - 1) / 2.0) * 14.0)
			var projectile := PROJECTILE_SCENE.instantiate()
			projectile.global_position = spawn_marker.global_position if spawn_marker else global_position
			projectile.direction = Vector2.from_angle(angle)
			projectile.speed = shard_speed
			projectile.damage = damage
			projectile.projectile_tint = Color(0.5, 0.9, 1.0)
			projectile.scale = Vector2(1.2, 1.2)
			get_parent().add_child(projectile)
	play_animation("move")
	is_casting = false
	if chase_target and is_instance_valid(chase_target):
		current_state = State.CHASE
	else:
		current_state = State.IDLE


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


func _summon_minions() -> void:
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
		var slime = MINION_SCENE.instantiate()
		var offset = Vector2(randf_range(-40, 40), randf_range(-40, 40))
		get_parent().add_child(slime)
		slime.global_position = global_position + offset
		slime.sprite.self_modulate = Color(0.5, 0.9, 1.0)
	play_animation("move")
	is_casting = false
	if chase_target and is_instance_valid(chase_target):
		current_state = State.CHASE
	else:
		current_state = State.IDLE


func _play_phase_effect() -> void:
	super()
	sprite.modulate = Color(0.7, 0.95, 1.0)
	var tween = create_tween()
	tween.tween_property(sprite, "scale", base_sprite_scale * 1.5, 0.25).set_trans(Tween.TRANS_ELASTIC)
	tween.tween_property(sprite, "scale", base_sprite_scale, 0.3).set_trans(Tween.TRANS_BACK)
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
		minion_count = 2
		shard_count = 4
	if current_phase >= 2:
		minion_count = 3
		shard_count = 5
		charge_damage = 3
