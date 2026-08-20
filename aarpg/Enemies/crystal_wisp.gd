class_name CrystalWisp
extends Enemy

const DATA = preload("res://aarpg/config/enemies/crystal_wisp_data.tres")


func _ready() -> void:
	enemy_data = DATA
	super()
