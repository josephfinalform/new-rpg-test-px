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


func _physics_process(delta: float) -> void:
	if is_charging:
		_process_charge(delta)
		return
	iceball_timer += delta
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
	if charge_timer >= charge_cooldown and dist < 100 and dist > 40:
		begin_chase_dash(&"charge_direction", &"charge_timer", charge_speed, charge_duration, charge_damage, &"charge_hit_cd", &"charge_time", &"is_charging")
		return
	if iceball_timer >= iceball_cooldown and dist < 150:
		_cast_iceball()
		return


func _cast_iceball() -> void:
	if not await _begin_cast(&"iceball_timer", iceball_cooldown):
		return
	if chase_target and is_instance_valid(chase_target):
		var dir = (chase_target.global_position - global_position).normalized()
		var fireball = PROJECTILE_SCENE.instantiate()
		fireball.global_position = spawn_marker.global_position if spawn_marker else global_position
		fireball.direction = dir
		fireball.speed = iceball_speed
		fireball.damage = damage
		fireball.projectile_tint = Color(0.55, 0.85, 1.0)
		fireball.scale = Vector2(1.3, 1.3)
		get_parent().add_child(fireball)
	_end_cast()


func _play_phase_effect() -> void:
	super()
	if current_phase == 1:
		iceball_cooldown = max(1.0, iceball_cooldown * 0.8)
		charge_cooldown = max(3.0, charge_cooldown * 0.8)
	elif current_phase == 2:
		iceball_cooldown = max(0.6, iceball_cooldown * 0.7)
		charge_cooldown = max(2.0, charge_cooldown * 0.7)
		summon_cooldown = max(5.0, summon_cooldown * 0.8)


func _apply_phase_scaling() -> void:
	super()
	if current_phase >= 2:
		charge_damage = 3
