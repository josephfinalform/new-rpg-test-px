class_name VenomArcher
extends GoblinArcher

const DATA = preload("res://aarpg/config/enemies/venom_archer_data.tres")


func _ready() -> void:
	enemy_data = DATA
	shoot_range = 180.0
	keep_distance = 140.0
	shoot_cooldown_time = 1.5
	arrow_speed = 125.0
	super()
