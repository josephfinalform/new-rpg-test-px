class_name PotionPickup
extends Area2D

@export var heal_amount: int = 4

var collected: bool = false
var _bob_time: float = 0.0
var _life: float = 15.0


func _ready() -> void:
	body_entered.connect(_on_body_entered)
	create_tween().tween_interval(_life).tween_callback(queue_free)


func _process(delta: float) -> void:
	_bob_time += delta
	position.y = -6.0 + sin(_bob_time * 3.5) * 2.5
	rotation += delta * 0.8


func _draw() -> void:
	draw_circle(Vector2.ZERO, 6.0, Color(0.85, 0.2, 0.45))
	draw_circle(Vector2(0, -1), 4.0, Color(1.0, 0.75, 0.85))
	draw_rect(Rect2(-1.5, -10.0, 3.0, 3.0), Color(1.0, 0.7, 0.8))
	draw_rect(Rect2(-2.5, -8.0, 5.0, 2.0), Color(1.0, 0.9, 0.9))


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
	tween.tween_property(self, "scale", Vector2(1.6, 1.6), 0.25).set_trans(Tween.TRANS_BACK)
	tween.chain().tween_callback(queue_free)
