class_name GoblinArcher
extends Enemy

const DATA = preload("res://aarpg/config/enemies/goblin_archer_data.tres")
const ARROW_SCENE = preload("res://aarpg/Enemies/boss_projectile.tscn")

@export var shoot_range: float = 170.0
@export var keep_distance: float = 130.0
@export var shoot_cooldown_time: float = 1.8
@export var arrow_speed: float = 115.0

var shoot_timer: float = 0.0


func _ready() -> void:
	enemy_data = DATA
	super()


func _physics_process(delta: float) -> void:
	if is_dead:
		return
	shoot_timer += delta
	super._physics_process(delta)


func _process_chase(_delta: float) -> void:
	if not chase_target or not is_instance_valid(chase_target):
		current_state = State.IDLE
		return
	var dist := global_position.distance_to(chase_target.global_position)
	var dir: Vector2 = (chase_target.global_position - global_position).normalized()
	if dist < keep_distance and dist > 40.0:
		velocity = -dir * move_speed
	elif dist > shoot_range * 0.8:
		velocity = dir * move_speed
	else:
		velocity = Vector2.ZERO
	base_velocity = velocity
	_update_chase_animation(dir)
	if shoot_timer >= shoot_cooldown_time and dist < shoot_range:
		shoot_timer = 0.0
		_shoot_arrow(dir)
	if dist < attack_range:
		current_state = State.ATTACK
		attack_cooldown = attack_cooldown_time


func _shoot_arrow(dir: Vector2) -> void:
	var arrow := ARROW_SCENE.instantiate()
	arrow.global_position = global_position
	arrow.direction = dir
	arrow.speed = arrow_speed
	arrow.damage = damage
	arrow.projectile_tint = enemy_data.tint if enemy_data else Color.WHITE
	arrow.scale = Vector2(0.7, 0.7)
	get_parent().add_child(arrow)
