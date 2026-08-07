class_name FireImp
extends Enemy

const TINT := Color(1.0, 0.5, 0.2)


func _ready() -> void:
	sprite.self_modulate = TINT
	sprite.scale = Vector2(0.7, 0.7)
	super()
