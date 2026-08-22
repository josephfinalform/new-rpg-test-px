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

const DATA = preload("res://aarpg/config/enemies/venom_king_data.tres")


func _ready() -> void:
	enemy_data = DATA
	super()


func _physics_process(delta: float) -> void:
	if is_dashing:
		process_dash(delta, dash_speed, dash_duration, dash_damage, &"dash_hit_cd", &"dash_time", &"is_dashing", dash_direction)
		return
	spit_timer += delta
	dash_timer += delta
	super(delta)


func _evaluate_special_attacks() -> void:
	if not chase_target or not is_instance_valid(chase_target):
		return
	var dist = global_position.distance_to(chase_target.global_position)
	if current_phase >= 1 and summon_timer >= summon_cooldown and dist < 160:
		summon_minions()
		return
	if dash_timer >= dash_cooldown and dist < 110 and dist > 45:
		begin_chase_dash(&"dash_direction", &"dash_timer", dash_speed, dash_duration, dash_damage, &"dash_hit_cd", &"dash_time", &"is_dashing")
		return
	if spit_timer >= spit_cooldown and dist < 150:
		_cast_spit()
		return


func _cast_spit() -> void:
	if not await _begin_cast(&"spit_timer"):
		return
	shoot_fan_projectiles(spit_count, spit_speed, 12.0, Color(0.45, 0.85, 0.4), Vector2(1.1, 1.1), spawn_marker)
	_end_cast()


func _apply_phase_scaling() -> void:
	super()
	_scale_attack_cooldown(&"spit_cooldown", 0.6)
	_scale_attack_cooldown(&"dash_cooldown", 2.0)
	if current_phase >= 1:
		spit_count = 4
	if current_phase >= 2:
		spit_count = 5
		dash_damage = 3
