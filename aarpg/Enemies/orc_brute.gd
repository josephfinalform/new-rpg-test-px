class_name OrcBrute
extends Goblin

const TINT := Color(0.32, 0.55, 0.3)


func _ready() -> void:
	sprite.self_modulate = TINT
	sprite.scale = Vector2(1.3, 1.3)
	max_health = 14
	move_speed = 34.0
	damage = 3
	xp_reward = 16
	knockback_resistance = 0.65
	knockback_force = 120.0
	attack_range = 28.0
	attack_cooldown_time = 0.8
	super()
