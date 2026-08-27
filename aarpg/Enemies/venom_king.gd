class_name VenomKing
extends BossEnemy

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
var attack_timers: Array[StringName] = [&"spit_timer", &"dash_timer"]

@onready var spawn_marker: Marker2D = $SpawnMarker

const _DATA := "res://aarpg/config/enemies/venom_king_data.tres"


func _get_data_path() -> String:
	return _DATA


func _process_special(delta: float) -> void:
	process_dash(delta, dash_speed, dash_duration, dash_damage, dash_direction)

func _evaluate_custom_attacks(dist: float) -> void:
	if dash_timer >= dash_cooldown and dist < 110 and dist > 45:
		begin_chase_dash(&"dash_timer", dash_speed, dash_duration, dash_damage)
		return
	if spit_timer >= spit_cooldown and dist < 150:
		_cast_spit()
		return


func _cast_spit() -> void:
	cast_fan_attack(&"spit_timer", spit_count, spit_speed, 12.0, Color(0.45, 0.85, 0.4), Vector2(1.1, 1.1), spawn_marker)


func _apply_phase_scaling() -> void:
	super()
	_scale_attack_cooldown(&"spit_cooldown", 0.6)
	_scale_attack_cooldown(&"dash_cooldown", 2.0)
	if current_phase >= 1:
		spit_count = 4
	if current_phase >= 2:
		spit_count = 5
		dash_damage = 3
