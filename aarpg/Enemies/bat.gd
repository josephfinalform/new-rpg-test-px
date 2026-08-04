class_name Bat
extends Enemy

const TINT := Color(0.55, 0.45, 0.85)


func _ready() -> void:
	sprite.self_modulate = TINT
	sprite.scale = Vector2(0.8, 0.8)
	super()
