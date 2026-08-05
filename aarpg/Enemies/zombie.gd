class_name Zombie
extends Goblin

const TINT := Color(0.42, 0.68, 0.38)


func _ready() -> void:
	sprite.self_modulate = TINT
	max_health = 10
	move_speed = 30.0
	damage = 2
	xp_reward = 12
	knockback_resistance = 0.7
	knockback_force = 100.0
	attack_range = 26.0
	attack_cooldown_time = 1.0
	idle_speed_ratio = 0.15
	potion_drop_chance = 0.05
	super()
