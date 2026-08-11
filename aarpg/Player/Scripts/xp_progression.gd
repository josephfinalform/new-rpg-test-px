class_name XpProgression
extends RefCounted

signal xp_changed(current_xp: int, level: int)
signal level_gained(new_level: int)
signal prestige_gained(new_prestige: int)

var level_config: LevelConfig
var level: int = 1
var xp: int = 0
var xp_to_next_level: int = 10
var prestige: int = 0
var prestige_xp: int = 0


func _init(config: LevelConfig) -> void:
	level_config = config
	level = clampi(config.starting_level, 1, config.max_level)
	xp = maxi(config.starting_xp, 0)
	xp_to_next_level = get_xp_for_level(level)


func gain_xp(amount: int) -> void:
	if amount <= 0:
		return
	if level >= level_config.max_level:
		_gain_prestige(amount)
		return
	xp += amount
	xp_changed.emit(xp, level)
	while xp >= xp_to_next_level:
		if level >= level_config.max_level:
			_gain_prestige(xp)
			xp = 0
			break
		xp -= xp_to_next_level
		_grant_level()
	xp_changed.emit(xp, level)


func gain_level() -> void:
	if level >= level_config.max_level:
		_gain_prestige(xp_to_next_level)
		return
	level += 1
	xp_to_next_level = get_xp_for_level(level)
	level_gained.emit(level)


func _grant_level() -> void:
	level += 1
	xp_to_next_level = get_xp_for_level(level)
	level_gained.emit(level)


func _gain_prestige(amount: int) -> void:
	prestige_xp += amount
	xp_changed.emit(prestige_xp, level)
	while prestige_xp >= level_config.prestige_xp_threshold:
		prestige_xp -= level_config.prestige_xp_threshold
		prestige += 1
		prestige_gained.emit(prestige)


func get_xp_for_level(lvl: int) -> int:
	if lvl > level_config.max_level:
		return 0
	if lvl - 1 < level_config.xp_curve.size():
		return level_config.xp_curve[lvl - 1]
	return 5 + lvl * 3
