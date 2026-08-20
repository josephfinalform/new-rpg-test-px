class_name StoneBrute
extends Enemy

const DATA = preload("res://aarpg/config/enemies/stone_brute_data.tres")


func _ready() -> void:
	enemy_data = DATA
	super()
