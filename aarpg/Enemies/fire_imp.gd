class_name FireImp
extends Enemy

const DATA = preload("res://aarpg/config/enemies/fire_imp_data.tres")


func _ready() -> void:
	enemy_data = DATA
	super()
