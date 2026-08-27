class_name CrystalGuardian
extends BossEnemy

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
var attack_timers: Array[StringName] = [&"shard_timer", &"charge_timer"]

@onready var spawn_marker: Marker2D = $SpawnMarker

const _DATA := "res://aarpg/config/enemies/crystal_guardian_data.tres"


func _get_data_path() -> String:
	return _DATA


func _evaluate_custom_attacks(dist: float) -> void:
	if charge_timer >= charge_cooldown and dist < 110 and dist > 45:
		begin_chase_dash(&"charge_timer", charge_speed, charge_duration, charge_damage)
		return
	if shard_timer >= shard_cooldown and dist < 160:
		_cast_shards()
		return


func _cast_shards() -> void:
	cast_fan_attack(&"shard_timer", shard_count, shard_speed, 14.0, Color(0.5, 0.9, 1.0), Vector2(1.2, 1.2), spawn_marker)


func _apply_phase_scaling() -> void:
	super()
	_scale_attack_cooldown(&"shard_cooldown", 0.6)
	_scale_attack_cooldown(&"charge_cooldown", 2.0)
	if current_phase >= 1:
		shard_count = 4
	if current_phase >= 2:
		shard_count = 5
		charge_damage = 3
