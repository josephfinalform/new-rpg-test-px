class_name AbyssalWraith
extends Enemy

const DATA = preload("res://aarpg/config/enemies/abyssal_wraith_data.tres")


func _ready() -> void:
	enemy_data = DATA
	super()
