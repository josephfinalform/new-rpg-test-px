class_name TreasureChest
extends Area2D

@export var heal_amount: int = 3
@export var xp_amount: int = 15

var collected: bool = false


func _ready() -> void:
	body_entered.connect(_on_body_entered)


func _on_body_entered(body: Node2D) -> void:
	if collected or not body is Player:
		return
	var player := body as Player
	if player.is_dead:
		return
	collected = true
	set_deferred("monitoring", false)
	player.heal(heal_amount)
	player.gain_xp(xp_amount)
	AudioManager.play_sfx_from_path("res://assets/audio/sfx/treasure_open.wav")
	var tween := create_tween()
	tween.set_parallel(true)
	tween.tween_property($Sprite2D, "scale", Vector2(1.5, 1.5), 0.25).set_trans(Tween.TRANS_BACK)
	tween.tween_property($Sprite2D, "modulate:a", 0.0, 0.4)
	tween.chain().tween_callback(queue_free)
