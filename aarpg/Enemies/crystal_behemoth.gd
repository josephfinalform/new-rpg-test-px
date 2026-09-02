class_name CrystalBehemoth
extends Enemy

@export_group("Behemoth Attacks")
@export var slam_cooldown: float = 3.0
@export var slam_radius: float = 50.0
@export var slam_damage: int = 3
@export var slam_interval: float = 1.5

var slam_timer: float = 0.0
var is_slamming: bool = false
var slam_time: float = 0.0

const _DATA := "res://aarpg/config/enemies/crystal_behemoth_data.tres"


func _get_data_path() -> String:
	return _DATA


func _physics_process(delta: float) -> void:
	super(delta)
	if is_dead:
		return
	slam_timer += delta
	if is_slamming:
		_process_slam(delta)
		return
	if current_state == State.CHASE or current_state == State.ATTACK:
		if slam_timer >= slam_cooldown and has_valid_target():
			var dist = global_position.distance_to(chase_target.global_position)
			if dist < slam_radius * 1.5:
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
	tween.tween_property(sprite, "self_modulate", Color(0.6, 0.9, 1.0), 0.2)
	tween.tween_property(sprite, "self_modulate", Color.WHITE, 0.15)
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
