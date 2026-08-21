class_name LevelConfig
extends Resource

const DEFAULT_RANKS: Array[Dictionary] = [
	{ "level": 1, "title": "NOVICE", "color": Color(0.6, 0.65, 0.7) },
	{ "level": 5, "title": "APPRENTICE", "color": Color(0.3, 0.9, 0.4) },
	{ "level": 12, "title": "JOURNEYMAN", "color": Color(0.3, 0.6, 1.0) },
	{ "level": 20, "title": "EXPERT", "color": Color(0.7, 0.4, 1.0) },
	{ "level": 30, "title": "MASTER", "color": Color(1.0, 0.55, 0.2) },
	{ "level": 42, "title": "GRANDMASTER", "color": Color(1.0, 0.85, 0.2) },
	{ "level": 55, "title": "OVERLORD", "color": Color(0.2, 0.85, 1.0) },
	{ "level": 70, "title": "MYTHIC", "color": Color(1.0, 0.3, 0.8) },
	{ "level": 85, "title": "LEGENDARY", "color": Color(1.0, 0.25, 0.25) },
	{ "level": 95, "title": "ETERNAL", "color": Color(1.0, 1.0, 1.0) },
	{ "level": 100, "title": "TRANSCENDENT", "color": Color(1.0, 0.92, 0.45) },
]

enum PrestigeTree { HP, ATK, SPD }

@export_group("Start Settings")
@export_range(1, 1000) var starting_level: int = 1
@export_range(0, 1000000) var starting_xp: int = 0

@export_group("Parchment (XP scrolls)")
@export_range(0, 100000) var parchment_xp: int = 15
@export var parchment_xp_multiplier: bool = true
@export_range(0, 100) var tome_levels: int = 1

@export_group("Level Cap")
@export_range(1, 1000) var max_level: int = 100

@export_group("XP Curve Design (5 phases - slower grind)")
@export_range(1, 10000) var curve_base_xp: int = 12
@export var curve_phases: Array[Dictionary] = [
	{ "end_level": 15, "growth": 4 },
	{ "end_level": 35, "growth": 8 },
	{ "end_level": 60, "growth": 18 },
	{ "end_level": 85, "growth": 40 },
	{ "end_level": 100, "growth": 80 },
]
@export var xp_curve: Array[int] = []

@export_group("Per-Level Bonuses (higher)")
@export_range(0, 100) var health_gain_per_level: int = 4
@export_range(0, 100) var heal_on_level_up: int = 6
@export_range(0, 100) var damage_gain_per_level: int = 2
@export_range(0.0, 500.0) var move_speed_gain: float = 10.0
@export_range(0.0, 500.0) var sprint_speed_gain: float = 15.0

@export_group("Milestone Bonuses (every N levels)")
@export_range(1, 100) var milestone_interval: int = 10
@export_range(0, 1000) var milestone_damage_bonus: int = 4
@export_range(0, 1000) var milestone_max_health_bonus: int = 10
@export_range(0.0, 1000.0) var milestone_speed_bonus: float = 20.0
@export_range(0.0, 100.0) var milestone_bonus_growth: float = 0.5

@export_group("Ranks (persona titles)")
@export var ranks: Array[Dictionary] = DEFAULT_RANKS

@export_group("Prestige System (new: points + escalation)")
@export_range(1, 1000000) var prestige_base_threshold: int = 1000
@export_range(1.0, 10.0) var prestige_threshold_growth: float = 1.5
@export_range(1, 10000000) var prestige_max_threshold: int = 10000
@export_range(0.0, 10.0) var prestige_xp_multiplier_per_rank: float = 0.05
@export_range(0, 1000) var prestige_hp_per_point: int = 5
@export_range(0.0, 100.0) var prestige_regen_per_point: float = 0.2
@export_range(0.0, 1.0) var prestige_lifesteal_per_point: float = 0.01
@export_range(0, 1000) var prestige_atk_per_point: int = 3
@export_range(0.0, 1.0) var prestige_crit_per_point: float = 0.05
@export_range(0.0, 10.0) var prestige_crit_damage_per_point: float = 0.10
@export_range(0, 1000) var prestige_speed_per_point: int = 10
@export_range(0.0, 1.0) var prestige_dash_reduction_per_point: float = 0.1
@export_range(0.0, 10.0) var prestige_magnet_per_point: float = 0.15
@export var prestige_title_tiers: Array[Dictionary] = [
	{ "min_prestige": 1, "max_prestige": 2, "stars": "\u2605", "title_suffix": "" },
	{ "min_prestige": 3, "max_prestige": 5, "stars": "\u2605\u2605", "title_suffix": "" },
	{ "min_prestige": 6, "max_prestige": 9, "stars": "\u2605\u2605\u2605", "title_suffix": "" },
	{ "min_prestige": 10, "max_prestige": 999, "stars": "\u2605\u2605\u2605\u2605", "title_suffix": " ASCENDED" },
]

@export_group("Combo (kill streak)")
@export_range(0.1, 60.0) var combo_window_time: float = 3.0
@export_range(0.0, 10.0) var combo_xp_per_step: float = 0.1
@export_range(1.0, 100.0) var combo_max_multiplier: float = 3.0


func build_xp_curve() -> Array[int]:
	var result: Array[int] = []
	var current := curve_base_xp
	var phase_index := 0
	for lvl in range(1, max_level + 1):
		result.append(current)
		while phase_index < curve_phases.size() and lvl >= int(curve_phases[phase_index].get("end_level", max_level)):
			phase_index += 1
		var growth := 4
		if phase_index < curve_phases.size():
			growth = int(curve_phases[phase_index].get("growth", 4))
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


func get_prestige_threshold(current_prestige: int) -> int:
	var threshold := prestige_base_threshold
	for i in range(current_prestige):
		threshold = mini(roundi(float(threshold) * prestige_threshold_growth), prestige_max_threshold)
	return threshold


func get_prestige_xp_multiplier(total_prestige: int) -> float:
	return 1.0 + total_prestige * prestige_xp_multiplier_per_rank


func get_prestige_title(prestige: int) -> String:
	if prestige <= 0:
		return ""
	for tier in prestige_title_tiers:
		if prestige >= int(tier.get("min_prestige", 1)) and prestige <= int(tier.get("max_prestige", 1)):
			var stars: String = str(tier.get("stars", ""))
			var suffix: String = str(tier.get("title_suffix", ""))
			return stars + suffix
	var last_tier: Dictionary = prestige_title_tiers[prestige_title_tiers.size() - 1]
	return str(last_tier.get("stars", "\u2605")) + str(prestige) + str(last_tier.get("title_suffix", ""))


func apply_prestige_point(tree: PrestigeTree, points: int) -> Dictionary:
	var result := {}
	match tree:
		PrestigeTree.HP:
			result["max_health"] = prestige_hp_per_point * points
			result["regen"] = prestige_regen_per_point * points
			result["lifesteal"] = prestige_lifesteal_per_point * points
		PrestigeTree.ATK:
			result["attack"] = prestige_atk_per_point * points
			result["crit_chance"] = prestige_crit_per_point * points
			result["crit_damage"] = prestige_crit_damage_per_point * points
		PrestigeTree.SPD:
			result["speed"] = prestige_speed_per_point * points
			result["dash_reduction"] = prestige_dash_reduction_per_point * points
			result["magnet"] = prestige_magnet_per_point * points
	return result
