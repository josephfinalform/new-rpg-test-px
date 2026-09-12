class_name ThunderColossus
extends Enemy

@export_group("Colossus Attacks")
@export var slam_cooldown: float = 2.8
@export var slam_radius: float = 50.0
@export var slam_damage: int = 4
@export var slam_interval: float = 1.4
@export var shock_bolt_cooldown: float = 4.0
@export var shock_bolt_speed: float = 120.0
@export var shock_bolt_scale: Vector2 = Vector2(1.2, 1.2)
@export var slam_flash: Color = Color(0.7, 0.9, 1.0)
@export var bolt_flash: Color = Color(0.6, 0.85, 1.0)
@export var bolt_tint: Color = Color(0.5, 0.85, 1.0)
@export var flash_restore: Color = Color.WHITE

var slam_timer: float = 0.0
var shock_timer: float = 0.0
var is_slamming: bool = false
var slam_time: float = 0.0
var is_casting: bool = false

const _DATA := "res://aarpg/config/enemies/thunder_colossus_data.tres"


func _get_data_path() -> String:
	return _DATA


func _physics_process(delta: float) -> void:
	super(delta)
	if is_dead:
		return
	slam_timer += delta
	shock_timer += delta
	if is_slamming:
		_process_slam(delta)
		return
	if current_state == State.CHASE or current_state == State.ATTACK:
		if has_valid_target():
			var dist = global_position.distance_to(chase_target.global_position)
			if shock_timer >= shock_bolt_cooldown and dist > slam_radius and dist < 260:
				_cast_shock_bolt()
			elif slam_timer >= slam_cooldown and dist < slam_radius * 1.5:
				_start_slam()


func _start_slam() -> void:
	if is_casting:
		return
	is_casting = true
	slam_timer = 0.0
	current_state = State.ATTACK
	velocity = Vector2.ZERO
	base_velocity = Vector2.ZERO
	var tween = create_tween()
	tween.tween_property(sprite, "self_modulate", slam_flash, 0.2)
	tween.tween_property(sprite, "self_modulate", flash_restore, 0.15)
	await tween.finished
	if is_dead:
		is_casting = false
		return
	is_slamming = true
	slam_time = 0.0


func _process_slam(delta: float) -> void:
	slam_time += delta
	velocity = Vector2.ZERO
	base_velocity = Vector2.ZERO
	move_and_slide()
	if slam_time >= slam_interval:
		is_slamming = false
		if has_valid_target():
			if global_position.distance_to(chase_target.global_position) < slam_radius:
				chase_target.take_damage(slam_damage, global_position)
		is_casting = false
		_resume_chase_or_idle()


func _cast_shock_bolt() -> void:
	if is_casting:
		return
	is_casting = true
	shock_timer = 0.0
	var tween = create_tween()
	tween.tween_property(sprite, "self_modulate", bolt_flash, 0.15)
	tween.tween_property(sprite, "self_modulate", flash_restore, 0.1)
	await tween.finished
	if is_dead:
		is_casting = false
		return
	if has_valid_target():
		var dir = (chase_target.global_position - global_position).normalized()
		spawn_projectile(dir, shock_bolt_speed, bolt_tint, shock_bolt_scale)
	is_casting = false
	_resume_chase_or_idle()


func _resume_chase_or_idle() -> void:
	if is_dead:
		return
	if has_valid_target():
		current_state = State.CHASE
	else:
		current_state = State.IDLE