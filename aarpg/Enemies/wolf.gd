class_name Wolf
extends Enemy

const TINT := Color(0.58, 0.52, 0.62)


func _ready() -> void:
	sprite.self_modulate = TINT
	sprite.scale = Vector2(0.9, 0.9)
	max_health = 4
	move_speed = 100.0
	damage = 1
	xp_reward = 9
	knockback_resistance = 0.2
	knockback_force = 200.0
	attack_range = 22.0
	attack_cooldown_time = 0.6
	idle_speed_ratio = 0.5
	heart_drop_chance = 0.1
	super()
