class_name LevelConfig
extends Resource

@export var max_level: int = 50
@export var xp_curve: Array[int] = []

@export_group("Per-Level Bonuses")
@export var health_gain_per_level: int = 2
@export var heal_on_level_up: int = 3
@export var damage_gain_per_level: int = 1
@export var move_speed_gain: float = 5.0
@export var sprint_speed_gain: float = 8.0
