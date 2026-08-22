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

const DATA = preload("res://aarpg/config/enemies/crystal_guardian_data.tres")


func _ready() -> void:
	enemy_data = DATA
	super()


func _physics_process(delta: float) -> void:
	if is_charging:
		_process_charge(delta)
		return
	shard_timer += delta
	charge_timer += delta
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
		begin_chase_dash(&"charge_direction", &"charge_timer", charge_speed, charge_duration, charge_damage, &"charge_hit_cd", &"charge_time", &"is_charging")
		return
	if shard_timer >= shard_cooldown and dist < 160:
		_cast_shards()
		return


func _cast_shards() -> void:
	if not await _begin_cast(&"shard_timer"):
		return
	shoot_fan_projectiles(shard_count, shard_speed, 14.0, Color(0.5, 0.9, 1.0), Vector2(1.2, 1.2), spawn_marker)
	_end_cast()


func _apply_phase_scaling() -> void:
	super()
	_scale_attack_cooldown(&"shard_cooldown", 0.6)
	_scale_attack_cooldown(&"charge_cooldown", 2.0)
	if current_phase >= 1:
		shard_count = 4
	if current_phase >= 2:
		shard_count = 5
		charge_damage = 3
