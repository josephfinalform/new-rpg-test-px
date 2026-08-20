class_name EnemyData
extends Resource

@export var display_name: String = ""
@export var max_health: int = 3
@export var move_speed: float = 40.0
@export var damage: int = 1
@export var xp_reward: int = 8
@export var knockback_resistance: float = 0.5
@export var knockback_force: float = 150.0

@export_group("AI Tuning")
@export var idle_speed_ratio: float = 0.3
@export var idle_duration_min: float = 1.0
@export var idle_duration_max: float = 3.0
@export var attack_range: float = 20.0
@export var attack_cooldown_time: float = 0.5

@export_group("Drops")
@export_range(0.0, 1.0) var heart_drop_chance: float = 0.15
@export_range(0.0, 1.0) var xp_gem_drop_chance: float = 0.0
@export_range(0.0, 1.0) var potion_drop_chance: float = 0.0
@export var xp_popup_enabled: bool = true

@export_group("Visual")
@export var tint: Color = Color.WHITE
@export var sprite_scale: Vector2 = Vector2.ONE

@export_group("Audio")
@export var death_sfx: AudioStream
@export var hit_sfx: AudioStream
