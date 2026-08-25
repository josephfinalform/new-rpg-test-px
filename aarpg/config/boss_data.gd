class_name BossData
extends EnemyData

@export_group("Boss")
@export var boss_name: String = "BOSS"
@export_range(0, 10000) var bonus_xp_reward: int = 50

@export_group("Minions")
@export var minion_scene: PackedScene
@export var minion_tint: Color = Color.WHITE
@export_range(0.0, 200.0) var minion_spawn_radius: float = 40.0
@export_range(1, 10) var summon_phase_threshold: int = 1
@export_range(0.0, 500.0) var summon_distance_threshold: float = 160.0
