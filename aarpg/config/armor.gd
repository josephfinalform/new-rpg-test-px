class_name Armor
extends Resource

@export var display_name: String = "Cloth Armor"
@export var damage_reduction: int = 0
@export_range(0.0, 1.0) var damage_reduction_ratio: float = 0.0
@export var speed_multiplier: float = 1.0
@export var armor_color: Color = Color(0.4, 0.8, 1.0)
@export_multiline var description: String = ""
