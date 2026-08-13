class_name VenomArcher
extends GoblinArcher

const TINT := Color(0.3, 0.6, 0.28)


func _ready() -> void:
	max_health = 8
	move_speed = 42.0
	damage = 2
	xp_reward = 16
	shoot_range = 180.0
	keep_distance = 140.0
	shoot_cooldown_time = 1.5
	arrow_speed = 125.0
	potion_drop_chance = 0.05
	super()
	sprite.self_modulate = TINT
