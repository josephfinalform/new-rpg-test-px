class_name AbyssLord
extends BossEnemy

enum SpecialAttack { VOID_BEAM, SHADOW_STEP, SUMMON }

@export_group("Abyss Lord Attacks")
@export var beam_cooldown: float = 2.5
@export var step_cooldown: float = 4.0
@export var beam_speed: float = 120.0
@export var beam_count: int = 5
@export var step_speed: float = 280.0
@export var step_duration: float = 0.4
@export var step_damage: int = 3

var beam_timer: float = 0.0
var step_timer: float = 0.0
var is_stepping: bool = false
var step_direction: Vector2 = Vector2.ZERO
var step_time: float = 0.0
var step_hit_cd: float = 0.0

const DATA = preload("res://aarpg/config/enemies/abyss_lord_data.tres")


func _ready() -> void:
	enemy_data = DATA
	super()


func _physics_process(delta: float) -> void:
	if is_stepping:
		_process_step(delta)
		return
	beam_timer += delta
	step_timer += delta
	super(delta)


func _process_step(delta: float) -> void:
	process_dash(delta, step_speed, step_duration, step_damage, &"step_hit_cd", &"step_time", &"is_stepping", step_direction, 26.0, 0.35)


func _evaluate_special_attacks() -> void:
	if not chase_target or not is_instance_valid(chase_target):
		return
	var dist = global_position.distance_to(chase_target.global_position)
	if current_phase >= 1 and summon_timer >= summon_cooldown and dist < 170:
		summon_minions()
		return
	if step_timer >= step_cooldown and dist < 120 and dist > 40:
		begin_chase_dash(&"step_direction", &"step_timer", step_speed, step_duration, step_damage, &"step_hit_cd", &"step_time", &"is_stepping")
		return
	if beam_timer >= beam_cooldown and dist < 160:
		_cast_void_beam()
		return


func _cast_void_beam() -> void:
	if not await _begin_cast(&"beam_timer"):
		return
	shoot_fan_projectiles(beam_count, beam_speed, 12.0, Color(0.55, 0.1, 0.7), Vector2(1.3, 1.3))
	_end_cast()


func _apply_phase_scaling() -> void:
	super()
	_scale_attack_cooldown(&"beam_cooldown", 0.7)
	_scale_attack_cooldown(&"step_cooldown", 1.5)
	if current_phase >= 1:
		beam_count = 6
	if current_phase >= 2:
		beam_count = 7
		step_damage = 4
