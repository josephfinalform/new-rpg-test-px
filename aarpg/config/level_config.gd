class_name LevelConfig
extends Resource

const DEFAULT_RANKS: Array[Dictionary] = [
	{ "level": 1, "title": "ROOKIE", "color": Color(0.7, 0.7, 0.75) },
	{ "level": 10, "title": "ADVENTURER", "color": Color(0.4, 1.0, 0.5) },
	{ "level": 20, "title": "VETERAN", "color": Color(0.4, 0.7, 1.0) },
	{ "level": 30, "title": "KNIGHT", "color": Color(0.75, 0.5, 1.0) },
	{ "level": 40, "title": "WARRIOR", "color": Color(1.0, 0.6, 0.3) },
	{ "level": 50, "title": "CHAMPION", "color": Color(1.0, 0.85, 0.3) },
	{ "level": 60, "title": "HERO", "color": Color(0.4, 0.9, 1.0) },
	{ "level": 70, "title": "LEGEND", "color": Color(1.0, 0.4, 0.9) },
	{ "level": 80, "title": "MYTHIC", "color": Color(1.0, 0.3, 0.3) },
	{ "level": 90, "title": "DIVINE", "color": Color(1.0, 1.0, 1.0) },
	{ "level": 100, "title": "GODLIKE", "color": Color(1.0, 0.9, 0.5) },
]

@export_group("Level Cap")
@export var max_level: int = 100

@export_group("XP Curve Design (phases)")
@export var curve_base_xp: int = 8
@export var curve_phases: Array[Dictionary] = [
	{ "end_level": 20, "growth": 3 },
	{ "end_level": 50, "growth": 5 },
	{ "end_level": 80, "growth": 12 },
	{ "end_level": 100, "growth": 35 },
]
@export var xp_curve: Array[int] = []

@export_group("Per-Level Bonuses")
@export var health_gain_per_level: int = 2
@export var heal_on_level_up: int = 3
@export var damage_gain_per_level: int = 1
@export var move_speed_gain: float = 5.0
@export var sprint_speed_gain: float = 8.0

@export_group("Milestone Bonuses (every N levels)")
@export var milestone_interval: int = 10
@export var milestone_damage_bonus: int = 2
@export var milestone_max_health_bonus: int = 5
@export var milestone_speed_bonus: float = 10.0
@export var milestone_bonus_growth: float = 0.5

@export_group("Ranks (persona titles)")
@export var ranks: Array[Dictionary] = DEFAULT_RANKS

@export_group("Prestige (beyond max level)")
@export var prestige_xp_threshold: int = 1000
@export var prestige_attack_bonus: int = 2
@export var prestige_health_bonus: int = 5
@export var prestige_speed_bonus: float = 3.0


func build_xp_curve() -> Array[int]:
	var result: Array[int] = []
	var current := curve_base_xp
	var phase_index := 0
	for lvl in range(1, max_level + 1):
		result.append(current)
		while phase_index < curve_phases.size() and lvl >= int(curve_phases[phase_index].get("end_level", max_level)):
			phase_index += 1
		var growth := 3
		if phase_index < curve_phases.size():
			growth = int(curve_phases[phase_index].get("growth", 3))
		current += growth
	return result


func _init() -> void:
	if xp_curve.is_empty():
		xp_curve = build_xp_curve()


func get_milestone_tier(lvl: int) -> int:
	if milestone_interval <= 0:
		return 0
	return lvl / milestone_interval


func get_milestone_multiplier(lvl: int) -> float:
	var tier := get_milestone_tier(lvl)
	return 1.0 + milestone_bonus_growth * float(tier - 1)


func get_rank_index(lvl: int) -> int:
	var index := 0
	for i in range(ranks.size()):
		if lvl >= int(ranks[i].get("level", 1)):
			index = i
	return index


func get_rank_title(lvl: int) -> String:
	if ranks.is_empty():
		return ""
	return str(ranks[get_rank_index(lvl)].get("title", ""))


func get_rank_color(lvl: int) -> Color:
	if ranks.is_empty():
		return Color.WHITE
	return ranks[get_rank_index(lvl)].get("color", Color.WHITE)


func get_prestige_title(prestige: int) -> String:
	if prestige <= 0:
		return ""
	var stars := ""
	for i in range(mini(prestige, 5)):
		stars += "★"
	if prestige > 5:
		stars += " x" + str(prestige)
	return stars
