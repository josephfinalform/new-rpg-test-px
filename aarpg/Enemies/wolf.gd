class_name Wolf
extends Enemy

const DATA = preload("res://aarpg/config/enemies/wolf_data.tres")


func _ready() -> void:
	enemy_data = DATA
	super()
