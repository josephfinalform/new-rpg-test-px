class_name HeartPickup
extends Area2D

@export var heal_amount: int = 1

var collected: bool = false
var _bob_time: float = 0.0
var _life: float = 12.0


func _ready() -> void:
	body_entered.connect(_on_body_entered)
	create_tween().tween_interval(_life).tween_callback(queue_free)


func _process(delta: float) -> void:
	_bob_time += delta
	position.y = -4.0 + sin(_bob_time * 4.0) * 2.0


func _draw() -> void:
	draw_circle(Vector2.ZERO, 7.0, Color(0.95, 0.25, 0.35))
	draw_circle(Vector2(0, -2), 5.0, Color(1.0, 0.65, 0.7))


func _on_body_entered(body: Node2D) -> void:
	if collected or not body is Player:
		return
	var player := body as Player
	if player.is_dead:
		return
	collected = true
	set_deferred("monitoring", false)
	player.heal(heal_amount)
	AudioManager.play_sfx_from_path("res://assets/audio/sfx/hp_up.wav")
	var tween := create_tween()
	tween.set_parallel(true)
	tween.tween_property(self, "modulate:a", 0.0, 0.3)
	tween.chain().tween_callback(queue_free)
