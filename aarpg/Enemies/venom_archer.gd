class_name VenomArcher
extends GoblinArcher

const _DATA := "res://aarpg/config/enemies/venom_archer_data.tres"


func _get_data_path() -> String:
	return _DATA


func _ready() -> void:
	shoot_range = 180.0
	keep_distance = 140.0
	shoot_cooldown_time = 1.5
	arrow_speed = 125.0
	super()
