class_name Bat
extends Enemy

const DATA = preload("res://aarpg/config/enemies/bat_data.tres")


func _ready() -> void:
	enemy_data = DATA
	super()
