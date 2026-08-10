class_name Armor
extends Resource

@export var display_name: String = "Cloth Armor"
@export var damage_reduction: int = 0
@export_range(0.0, 1.0) var damage_reduction_ratio: float = 0.0
@export var speed_multiplier: float = 1.0
@export var armor_color: Color = Color(0.4, 0.8, 1.0)
@export_multiline var description: String = ""

@export_group("Armor v2")
@export var armor_tier: int = 1
@export var xp_multiplier: float = 1.0
@export var dash_cooldown_multiplier: float = 1.0
@export var move_speed_multiplier: float = 1.0
