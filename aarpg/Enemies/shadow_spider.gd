class_name ShadowSpider
extends Enemy

const DATA = preload("res://aarpg/config/enemies/shadow_spider_data.tres")


func _ready() -> void:
	enemy_data = DATA
	super()
