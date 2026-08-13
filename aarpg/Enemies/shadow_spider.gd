class_name ShadowSpider
extends Enemy

const TINT := Color(0.28, 0.22, 0.38)


func _ready() -> void:
	sprite.self_modulate = TINT
	sprite.scale = Vector2(0.65, 0.65)
	max_health = 4
	move_speed = 88.0
	damage = 1
	xp_reward = 10
	knockback_resistance = 0.15
	knockback_force = 200.0
	attack_range = 18.0
	attack_cooldown_time = 0.5
	idle_speed_ratio = 0.5
	idle_duration_min = 0.4
	idle_duration_max = 1.0
	heart_drop_chance = 0.1
	super()
