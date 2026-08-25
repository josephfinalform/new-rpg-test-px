class_name IceGolem
extends BossEnemy

enum SpecialAttack { ICEBALL, CHARGE, SUMMON }

@export_group("Golem Attacks")
@export var iceball_cooldown: float = 2.2
@export var charge_cooldown: float = 5.0
@export var iceball_speed: float = 110.0
@export var charge_speed: float = 240.0
@export var charge_duration: float = 0.6
@export var charge_damage: int = 2

var iceball_timer: float = 0.0
var charge_timer: float = 0.0
var is_charging: bool = false
var charge_direction: Vector2 = Vector2.ZERO
var charge_time: float = 0.0
var charge_hit_cd: float = 0.0

@onready var spawn_marker: Marker2D = $SpawnMarker

const DATA = preload("res://aarpg/config/enemies/ice_golem_data.tres")


func _ready() -> void:
	enemy_data = DATA
	super()


func _is_special_active() -> bool:
	return is_charging

func _process_special(delta: float) -> void:
	_process_charge(delta)

func _update_attack_timers(delta: float) -> void:
	iceball_timer += delta
	charge_timer += delta


func _process_charge(delta: float) -> void:
	process_dash(delta, charge_speed, charge_duration, charge_damage, &"charge_hit_cd", &"charge_time", &"is_charging", charge_direction)


func _evaluate_custom_attacks(dist: float) -> void:
	if charge_timer >= charge_cooldown and dist < 100 and dist > 40:
		begin_chase_dash(&"charge_direction", &"charge_timer", charge_speed, charge_duration, charge_damage, &"charge_hit_cd", &"charge_time", &"is_charging")
		return
	if iceball_timer >= iceball_cooldown and dist < 150:
		_cast_iceball()
		return


func _cast_iceball() -> void:
	if not await _begin_cast(&"iceball_timer"):
		return
	if chase_target and is_instance_valid(chase_target):
		var dir = (chase_target.global_position - global_position).normalized()
		spawn_projectile(dir, iceball_speed, Color(0.55, 0.85, 1.0), Vector2(1.3, 1.3), spawn_marker)
	_end_cast()


func _apply_phase_scaling() -> void:
	super()
	_scale_attack_cooldown(&"iceball_cooldown", 0.6)
	_scale_attack_cooldown(&"charge_cooldown", 2.0)
	if current_phase >= 2:
		charge_damage = 3
