class_name XpGem
extends Area2D

const XP_POPUP = preload("res://aarpg/Effects/floating_text.tscn")

@export var xp_amount: int = 5

@export_group("Magnet")
@export var magnet_radius: float = 70.0
@export var magnet_speed: float = 240.0
@export var magnet_accel: float = 900.0

var collected: bool = false
var _magnet_velocity: Vector2 = Vector2.ZERO
var _bob_time: float = 0.0
var _life: float = 15.0


func _ready() -> void:
	body_entered.connect(_on_body_entered)
	var size_scale := 1.0 + 0.04 * float(xp_amount)
	scale = Vector2(size_scale, size_scale)
	create_tween().tween_interval(_life).tween_callback(queue_free)


func _process(delta: float) -> void:
	_bob_time += delta
	position.y = -4.0 + sin(_bob_time * 5.0) * 2.0
	rotation += delta * 1.5
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
	if dist > magnet_radius:
		return
	var dir := to_player / maxf(dist, 0.001)
	_magnet_velocity = _magnet_velocity.move_toward(dir * magnet_speed, magnet_accel * delta)
	global_position += _magnet_velocity * delta


func _draw() -> void:
	draw_circle(Vector2.ZERO, 5.5, Color(0.2, 0.65, 1.0))
	draw_circle(Vector2.ZERO, 3.0, Color(0.75, 0.92, 1.0))


func _on_body_entered(body: Node2D) -> void:
	if collected or not body is Player:
		return
	var player := body as Player
	if player.is_dead:
		return
	collected = true
	set_deferred("monitoring", false)
	player.gain_xp(xp_amount)
	var popup := XP_POPUP.instantiate() as Label
	get_parent().add_child(popup)
	popup.text = "+" + str(xp_amount) + " XP"
	popup.modulate = Color(0.35, 0.75, 1.0)
	popup.global_position = global_position + Vector2(0, -10)
	AudioManager.play_sfx_from_path("res://assets/audio/sfx/item_pickup.wav")
	var tween := create_tween()
	tween.set_parallel(true)
	tween.tween_property(self, "modulate:a", 0.0, 0.3)
	tween.chain().tween_callback(queue_free)
