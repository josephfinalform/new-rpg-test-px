class_name VampireLord
extends BossEnemy

@export_group("Vampire Attacks")
@export var blood_bolt_cooldown: float = 2.0
@export var blood_siphon_cooldown: float = 5.0
@export var swarm_cooldown: float = 7.0
@export var blood_bolt_speed: float = 140.0
@export var siphon_range: float = 70.0
@export var siphon_damage: int = 3
@export var siphon_heal_ratio: float = 0.5

var blood_bolt_timer: float = 0.0
var blood_siphon_timer: float = 0.0
var swarm_timer: float = 0.0
var attack_timers: Array[StringName] = [&"blood_bolt_timer", &"blood_siphon_timer", &"swarm_timer"]

@onready var spawn_marker: Marker2D = $SpawnMarker

const _DATA := "res://aarpg/config/enemies/vampire_lord_data.tres"


func _get_data_path() -> String:
	return _DATA


func _evaluate_custom_attacks(dist: float) -> void:
	if blood_siphon_timer >= blood_siphon_cooldown and dist < siphon_range:
		_cast_siphon()
		return
	if blood_bolt_timer >= blood_bolt_cooldown and dist < 150:
		_cast_blood_bolt()
		return


func _cast_blood_bolt() -> void:
	cast_single_attack(&"blood_bolt_timer", blood_bolt_speed, Color(0.8, 0.1, 0.15), Vector2(1.2, 1.2), spawn_marker)


func _cast_siphon() -> void:
	if not await _begin_cast(&"blood_siphon_timer", 0.3):
		return
	if has_valid_target():
		var dir = (chase_target.global_position - global_position).normalized()
		spawn_projectile(dir, blood_bolt_speed * 0.7, Color(1.0, 0.0, 0.2), Vector2(1.5, 1.5), spawn_marker)
		if global_position.distance_to(chase_target.global_position) < siphon_range:
			chase_target.take_damage(siphon_damage, global_position)
			var heal = ceili(float(siphon_damage) * siphon_heal_ratio)
			health = mini(health + heal, max_health)
	_end_cast()


func summon_minions() -> void:
	await super()
	minion_tint = Color(0.6, 0.05, 0.1)


func _apply_phase_scaling() -> void:
	super()
	_scale_attack_cooldown(&"blood_bolt_cooldown", 0.6)
	_scale_attack_cooldown(&"blood_siphon_cooldown", 1.5)
	_scale_attack_cooldown(&"swarm_cooldown", 2.0)
	if current_phase >= 2:
		siphon_damage = 4
		siphon_heal_ratio = 0.7
