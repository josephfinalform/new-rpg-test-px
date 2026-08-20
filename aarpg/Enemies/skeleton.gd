class_name Skeleton
extends Enemy

const DATA = preload("res://aarpg/config/enemies/skeleton_data.tres")


func _ready() -> void:
	enemy_data = DATA
	super()
