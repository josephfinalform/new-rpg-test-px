class_name GoblinElite
extends Enemy

const DATA = preload("res://aarpg/config/enemies/goblin_elite_data.tres")


func _ready() -> void:
	enemy_data = DATA
	super()
