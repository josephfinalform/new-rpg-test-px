class_name AbyssalWraith
extends Goblin

const TINT := Color(0.45, 0.15, 0.65)


func _ready() -> void:
	max_health = 8
	move_speed = 58.0
	damage = 2
	xp_reward = 18
	knockback_resistance = 0.3
	knockback_force = 120.0
	attack_range = 24.0
	attack_cooldown_time = 0.45
	xp_gem_drop_chance = 0.25
	potion_drop_chance = 0.05
	sprite.self_modulate = TINT
	sprite.scale = Vector2(1.1, 1.1)
	super()
