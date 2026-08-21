class_name Weapon
extends Resource

enum Effect { NONE, FIRE, FROST, SHOCK }

@export var display_name: String = "Iron Sword"
@export_range(0, 100) var damage_bonus: int = 0
@export_range(0.1, 5.0) var cooldown_multiplier: float = 1.0
@export var effect: Effect = Effect.NONE
@export var trail_color: Color = Color(0.85, 0.85, 0.9)
@export_multiline var description: String = ""
