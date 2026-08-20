class_name CrystalSlime
extends Enemy

const DATA = preload("res://aarpg/config/enemies/crystal_slime_data.tres")


func _ready() -> void:
	enemy_data = DATA
	super()
