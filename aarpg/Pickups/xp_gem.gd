class_name XpGem
extends Area2D

@export var xp_amount: int = 5

var collected: bool = false
var _bob_time: float = 0.0
var _life: float = 15.0


func _ready() -> void:
	body_entered.connect(_on_body_entered)
	create_tween().tween_interval(_life).tween_callback(queue_free)


func _process(delta: float) -> void:
	_bob_time += delta
	position.y = -4.0 + sin(_bob_time * 5.0) * 2.0
	rotation += delta * 1.5


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
	AudioManager.play_sfx_from_path("res://assets/audio/sfx/item_pickup.wav")
	var tween := create_tween()
	tween.set_parallel(true)
	tween.tween_property(self, "modulate:a", 0.0, 0.3)
	tween.chain().tween_callback(queue_free)
