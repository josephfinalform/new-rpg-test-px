class_name VenomSlime
extends Enemy

const DATA = preload("res://aarpg/config/enemies/venom_slime_data.tres")


func _ready() -> void:
	enemy_data = DATA
	super()
