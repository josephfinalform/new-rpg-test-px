class_name OrcBrute
extends Enemy

const DATA = preload("res://aarpg/config/enemies/orc_brute_data.tres")


func _ready() -> void:
	enemy_data = DATA
	super()
