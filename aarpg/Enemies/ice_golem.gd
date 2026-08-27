class_name IceGolem
extends BossEnemy

@export_group("Golem Attacks")
@export var iceball_cooldown: float = 2.2
@export var charge_cooldown: float = 5.0
@export var iceball_speed: float = 110.0
@export var charge_speed: float = 240.0
@export var charge_duration: float = 0.6
@export var charge_damage: int = 2

var iceball_timer: float = 0.0
var charge_timer: float = 0.0
var attack_timers: Array[StringName] = [&"iceball_timer", &"charge_timer"]

@onready var spawn_marker: Marker2D = $SpawnMarker

const _DATA := "res://aarpg/config/enemies/ice_golem_data.tres"


func _get_data_path() -> String:
	return _DATA


func _evaluate_custom_attacks(dist: float) -> void:
	if charge_timer >= charge_cooldown and dist < 100 and dist > 40:
		begin_chase_dash(&"charge_timer", charge_speed, charge_duration, charge_damage)
		return
	if iceball_timer >= iceball_cooldown and dist < 150:
		_cast_iceball()
		return


func _cast_iceball() -> void:
	cast_single_attack(&"iceball_timer", iceball_speed, Color(0.55, 0.85, 1.0), Vector2(1.3, 1.3), spawn_marker)


func _apply_phase_scaling() -> void:
	super()
	_scale_attack_cooldown(&"iceball_cooldown", 0.6)
	_scale_attack_cooldown(&"charge_cooldown", 2.0)
	if current_phase >= 2:
		charge_damage = 3
