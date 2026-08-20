class_name GoblinElite
extends Enemy


func _ready() -> void:
	max_health = 12
	move_speed = 65.0
	damage = 3
	xp_reward = 20
	attack_range = 26.0
	attack_cooldown_time = 0.5
	potion_drop_chance = 0.08
	super()
