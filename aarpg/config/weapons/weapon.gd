class_name Weapon
extends Resource

enum Effect { NONE, FIRE, FROST }

@export var display_name: String = "Iron Sword"
@export var damage_bonus: int = 0
@export var cooldown_multiplier: float = 1.0
@export var effect: Effect = Effect.NONE
@export var trail_color: Color = Color(0.85, 0.85, 0.9)
@export_multiline var description: String = ""
