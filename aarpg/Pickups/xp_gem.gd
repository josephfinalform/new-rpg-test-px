class_name XpGem
extends PickupBase

@export var xp_amount: int = 5

@export_group("Magnet")
@export var magnet_radius: float = 70.0
@export var magnet_speed: float = 240.0
@export var magnet_accel: float = 900.0

var _magnet_velocity: Vector2 = Vector2.ZERO


func _ready() -> void:
	bob_speed = 5.0
	bob_amplitude = 2.0
	bob_base_y = -4.0
	rotation_speed = 1.5
	lifetime = 15.0
	var size_scale := 1.0 + 0.04 * float(xp_amount)
	scale = Vector2(size_scale, size_scale)
	super._ready()


func _process(delta: float) -> void:
	super._process(delta)
	_process_magnet(delta)


func _process_magnet(delta: float) -> void:
	if collected:
		return
	var players := get_tree().get_nodes_in_group("player")
	if players.is_empty():
		return
	var player := players[0] as Player
	if player.is_dead:
		return
	var to_player: Vector2 = player.global_position - global_position
	var dist: float = to_player.length()
	if dist > player.get_xp_magnet_radius(magnet_radius):
		return
	var dir := to_player / maxf(dist, 0.001)
	_magnet_velocity = _magnet_velocity.move_toward(dir * magnet_speed, magnet_accel * delta)
	global_position += _magnet_velocity * delta


func _draw() -> void:
	draw_circle(Vector2.ZERO, 5.5, Color(0.2, 0.65, 1.0))
	draw_circle(Vector2.ZERO, 3.0, Color(0.75, 0.92, 1.0))


func _apply_effect(player: Player) -> void:
	player.gain_xp(xp_amount)
	_spawn_popup("+" + str(xp_amount) + " XP", Color(0.35, 0.75, 1.0))
