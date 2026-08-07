class_name CrystalWisp
extends Enemy

const TINT := Color(0.55, 0.9, 1.0)


func _ready() -> void:
	sprite.self_modulate = TINT
	sprite.scale = Vector2(0.75, 0.75)
	super()
