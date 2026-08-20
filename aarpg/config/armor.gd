class_name Armor
extends Resource

@export var display_name: String = "Cloth Armor"
@export_range(0, 100) var damage_reduction: int = 0
@export_range(0.0, 1.0) var damage_reduction_ratio: float = 0.0
@export_range(0.5, 2.0) var speed_multiplier: float = 1.0
@export var armor_color: Color = Color(0.4, 0.8, 1.0)
@export_multiline var description: String = ""

@export_group("Advanced Stats")
@export_range(1, 10) var armor_tier: int = 1
@export_range(0.5, 3.0) var xp_multiplier: float = 1.0
@export_range(0.5, 2.0) var dash_cooldown_multiplier: float = 1.0
@export_range(0.5, 2.0) var move_speed_multiplier: float = 1.0
