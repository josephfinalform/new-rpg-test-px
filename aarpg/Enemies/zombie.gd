class_name Zombie
extends Enemy

const DATA = preload("res://aarpg/config/enemies/zombie_data.tres")


func _ready() -> void:
	enemy_data = DATA
	super()
