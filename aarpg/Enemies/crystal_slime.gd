class_name CrystalSlime
extends Slime

const TINT := Color(0.5, 0.9, 1.0)


func _ready() -> void:
	sprite.self_modulate = TINT
	sprite.scale = Vector2(1.15, 1.15)
	max_health = 10
	move_speed = 40.0
	damage = 2
	xp_reward = 16
	knockback_resistance = 0.5
	knockback_force = 130.0
	attack_range = 22.0
	attack_cooldown_time = 0.65
	xp_gem_drop_chance = 0.35
	potion_drop_chance = 0.05
	super()
