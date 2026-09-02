class_name Lich
extends Enemy

@export_group("Lich Attacks")
@export var orb_cooldown: float = 3.0
@export var orb_speed: float = 100.0
@export var drain_range: float = 60.0
@export var drain_cooldown: float = 5.0
@export var drain_amount: int = 1

var orb_timer: float = 0.0
var drain_timer: float = 0.0
var attack_timers: Array[StringName] = [&"orb_timer", &"drain_timer"]

const _DATA := "res://aarpg/config/enemies/lich_data.tres"


func _get_data_path() -> String:
	return _DATA


func _physics_process(delta: float) -> void:
	super(delta)
	if is_dead:
		return
	for timer_ref in attack_timers:
		set(timer_ref, float(get(timer_ref)) + delta)
	if current_state == State.CHASE or current_state == State.ATTACK:
		_evaluate_attacks()


func _evaluate_attacks() -> void:
	if not has_valid_target():
		return
	var dist := global_position.distance_to(chase_target.global_position)
	if orb_timer >= orb_cooldown and dist < 150:
		_cast_orb()
		return
	if drain_timer >= drain_cooldown and dist < drain_range:
		_drain_life()


func _cast_orb() -> void:
	if is_casting:
		return
	is_casting = true
	orb_timer = 0.0
	play_animation("idle")
	await get_tree().create_timer(0.3).timeout
	if is_dead:
		is_casting = false
		return
	if has_valid_target():
		var dir = (chase_target.global_position - global_position).normalized()
		spawn_projectile(dir, orb_speed, Color(0.5, 0.1, 0.8))
	is_casting = false
	_resume_chase_or_idle()


func _drain_life() -> void:
	if not has_valid_target():
		return
	if is_casting:
		return
	is_casting = true
	drain_timer = 0.0
	current_state = State.ATTACK
	velocity = Vector2.ZERO
	base_velocity = Vector2.ZERO
	play_animation("idle")
	var drain_tween = create_tween()
	drain_tween.tween_property(sprite, "self_modulate", Color(0.7, 0.2, 1.0), 0.15)
	drain_tween.tween_property(sprite, "self_modulate", Color.WHITE, 0.3)
	if global_position.distance_to(chase_target.global_position) < drain_range:
		chase_target.take_damage(drain_amount, global_position)
		health = mini(health + drain_amount, max_health)
	await drain_tween.finished
	is_casting = false
	_resume_chase_or_idle()
