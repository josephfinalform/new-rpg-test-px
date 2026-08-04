class_name Skeleton
extends Enemy

const TINT := Color(0.82, 0.82, 0.72)


func _ready() -> void:
	sprite.self_modulate = TINT
	super()
