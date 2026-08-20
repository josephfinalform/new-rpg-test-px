class_name VenomSlime
extends Enemy

const TINT := Color(0.35, 0.8, 0.4)


func _ready() -> void:
	sprite.self_modulate = TINT
	sprite.scale = Vector2(1.1, 1.1)
	max_health = 7
	move_speed = 42.0
	damage = 2
	xp_reward = 14
	knockback_resistance = 0.4
	knockback_force = 140.0
	attack_range = 22.0
	attack_cooldown_time = 0.7
	potion_drop_chance = 0.06
	super()
