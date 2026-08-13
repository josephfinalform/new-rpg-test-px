class_name StoneBrute
extends OrcBrute

const TINT := Color(0.52, 0.55, 0.6)


func _ready() -> void:
	super()
	max_health = 26
	health = max_health
	move_speed = 26.0
	damage = 4
	xp_reward = 26
	knockback_resistance = 0.85
	knockback_force = 100.0
	attack_range = 30.0
	attack_cooldown_time = 1.1
	heart_drop_chance = 0.25
	sprite.self_modulate = TINT
	sprite.scale = Vector2(1.5, 1.5)
