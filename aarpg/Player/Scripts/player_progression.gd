class_name PlayerProgressionHandler
extends RefCounted

const BASE_MAX_HP := 6
const STAT_CAP_CRIT := 0.5
const STAT_CAP_LIFESTEAL := 0.5
const STAT_CAP_CRIT_DAMAGE := 4.0
const STAT_CAP_ATTACK_SPEED := 0.4
const GEAR_MULT_DASH := 0.05
const GEAR_MULT_CRIT := 0.05
const GEAR_MULT_LIFESTEAL := 0.05
const GEAR_MULT_FURY := 0.05
const GEAR_MULT_XP := 0.1
const GEAR_MULT_MAGNET := 0.5
const GEAR_MULT_REGEN := 0.25
const GEAR_MULT_KNOCKBACK := 0.25
const GEAR_MULT_CRIT_DAMAGE := 0.25

var player: Player

var xp_bonus: float = 0.0
var gear_speed_bonus: float = 0.0
var gear_dash_reduction: float = 0.0
var magnet_radius_bonus: float = 0.0
var regen_per_second: float = 0.0

var prestige_hp_bonus: int = 0
var prestige_atk_bonus: int = 0
var prestige_spd_bonus: int = 0
var prestige_regen_bonus: float = 0.0
var prestige_lifesteal_bonus: float = 0.0
var prestige_crit_bonus: float = 0.0
var prestige_crit_damage_bonus: float = 0.0
var prestige_dash_reduction_bonus: float = 0.0
var prestige_magnet_bonus: float = 0.0

var level_move_bonus: float = 0.0
var level_sprint_bonus: float = 0.0


func _init(p: Player) -> void:
	player = p


func gain_xp(amount: int) -> void:
	amount = maxi(roundi(amount * get_xp_multiplier()), 1)
	player.xp_progression.gain_xp(amount)


func gain_xp_flat(amount: int) -> void:
	player.xp_progression.gain_xp(maxi(amount, 0))


func gain_level() -> void:
	player.xp_progression.gain_level()


func get_xp_multiplier() -> float:
	var mult := 1.0 + xp_bonus
	if player.equipped_armor:
		mult *= player.equipped_armor.xp_multiplier
	mult *= GameManager.get_combo_multiplier()
	mult *= player.xp_progression.get_xp_multiplier()
	return mult


func get_xp_magnet_radius(base_radius: float) -> float:
	return base_radius * (1.0 + magnet_radius_bonus)


func apply_level_up() -> void:
	var config := player.level_config
	_grant_level_stats(config.health_gain_per_level, config.heal_on_level_up, config.damage_gain_per_level, config.move_speed_gain, config.sprint_speed_gain)
	_apply_milestone_bonus()
	player.health_changed.emit(player.health)
	player.level_up.emit(player.level)
	player._spawn_level_up_effect()
	player._animate_level_scale()


func _grant_level_stats(hp_gain: int, heal_amount: int, dmg_gain: int, move_gain: float, sprint_gain: float) -> void:
	player.max_health += hp_gain
	player.health = min(player.health + heal_amount, player.max_health)
	player.base_attack_damage += dmg_gain
	player.combat.apply_weapon()
	level_move_bonus += move_gain
	level_sprint_bonus += sprint_gain
	player._recalculate_speed()


func _apply_milestone_bonus() -> void:
	var config := player.level_config
	if config.milestone_interval <= 0:
		return
	if player.level % config.milestone_interval != 0:
		return
	var mult := maxf(config.get_milestone_multiplier(player.level), 1.0)
	var hp_bonus := maxi(roundi(config.milestone_max_health_bonus * mult), 1)
	var dmg_bonus := maxi(roundi(config.milestone_damage_bonus * mult), 1)
	var spd_bonus := config.milestone_speed_bonus * mult
	_grant_level_stats(hp_bonus, hp_bonus, dmg_bonus, spd_bonus, spd_bonus)


func apply_prestige_tree_bonuses() -> void:
	var config := player.level_config
	var hp_stats: Dictionary = config.apply_prestige_point(LevelConfig.PrestigeTree.HP, player.xp_progression.prestige_tree_hp)
	prestige_hp_bonus = hp_stats.get("max_health", 0)
	prestige_regen_bonus = hp_stats.get("regen", 0.0)
	prestige_lifesteal_bonus = hp_stats.get("lifesteal", 0.0)

	var atk_stats: Dictionary = config.apply_prestige_point(LevelConfig.PrestigeTree.ATK, player.xp_progression.prestige_tree_atk)
	prestige_atk_bonus = atk_stats.get("attack", 0)
	prestige_crit_bonus = atk_stats.get("crit_chance", 0.0)
	prestige_crit_damage_bonus = atk_stats.get("crit_damage", 0.0)

	var spd_stats: Dictionary = config.apply_prestige_point(LevelConfig.PrestigeTree.SPD, player.xp_progression.prestige_tree_spd)
	prestige_spd_bonus = spd_stats.get("speed", 0)
	prestige_dash_reduction_bonus = spd_stats.get("dash_reduction", 0.0)
	prestige_magnet_bonus = spd_stats.get("magnet", 0.0)

	player.max_health = base_max_health() + prestige_hp_bonus
	player.health = min(player.health, player.max_health)
	player.combat.apply_weapon()
	level_move_bonus += prestige_spd_bonus
	level_sprint_bonus += prestige_spd_bonus
	player.combat.crit_chance = minf(player.combat.crit_chance + prestige_crit_bonus, STAT_CAP_CRIT)
	player.combat.lifesteal = minf(player.combat.lifesteal + prestige_lifesteal_bonus, STAT_CAP_LIFESTEAL)
	player.combat.crit_damage_multiplier = minf(player.combat.crit_damage_multiplier + prestige_crit_damage_bonus, STAT_CAP_CRIT_DAMAGE)
	regen_per_second += prestige_regen_bonus
	gear_dash_reduction += prestige_dash_reduction_bonus
	magnet_radius_bonus += prestige_magnet_bonus
	player._apply_dash_cooldown()
	player._recalculate_speed()
	player.health_changed.emit(player.health)


func base_max_health() -> int:
	var config := player.level_config
	var hp := BASE_MAX_HP
	hp += config.health_gain_per_level * (player.level - 1)
	if config.milestone_interval > 0:
		var milestones := (player.level - 1) / config.milestone_interval
		for i in range(1, milestones + 1):
			var mult := maxf(config.get_milestone_multiplier(i * config.milestone_interval), 1.0)
			hp += maxi(roundi(config.milestone_max_health_bonus * mult), 1)
	return hp


func apply_gear_up(gear_up: GearUp) -> void:
	match gear_up.stat:
		GearUp.Stat.ATTACK:
			player.base_attack_damage += gear_up.amount
			player.combat.apply_weapon()
		GearUp.Stat.MAX_HEALTH:
			player.max_health += gear_up.amount
			player.health = min(player.health + gear_up.amount, player.max_health)
			player.health_changed.emit(player.health)
		GearUp.Stat.SPEED:
			gear_speed_bonus += float(gear_up.amount)
			player._recalculate_speed()
		GearUp.Stat.DASH_COOLDOWN:
			gear_dash_reduction += gear_up.amount * GEAR_MULT_DASH
			player._apply_dash_cooldown()
		GearUp.Stat.CRIT_CHANCE:
			player.combat.crit_chance = minf(player.combat.crit_chance + float(gear_up.amount) * GEAR_MULT_CRIT, STAT_CAP_CRIT)
		GearUp.Stat.LIFESTEAL:
			player.combat.lifesteal = minf(player.combat.lifesteal + float(gear_up.amount) * GEAR_MULT_LIFESTEAL, STAT_CAP_LIFESTEAL)
		GearUp.Stat.XP_BONUS:
			xp_bonus += float(gear_up.amount) * GEAR_MULT_XP
		GearUp.Stat.ARMOR:
			player.combat.gear_armor_reduction += gear_up.amount
		GearUp.Stat.THORNS:
			player.combat.thorns_damage += gear_up.amount
		GearUp.Stat.MAGNET:
			magnet_radius_bonus += float(gear_up.amount) * GEAR_MULT_MAGNET
		GearUp.Stat.REGEN:
			regen_per_second += float(gear_up.amount) * GEAR_MULT_REGEN
		GearUp.Stat.FURY:
			player.combat.attack_speed_multiplier = maxf(player.combat.attack_speed_multiplier - float(gear_up.amount) * GEAR_MULT_FURY, STAT_CAP_ATTACK_SPEED)
			player.combat.apply_weapon()
		GearUp.Stat.KNOCKBACK:
			player.combat.knockback_multiplier += float(gear_up.amount) * GEAR_MULT_KNOCKBACK
		GearUp.Stat.CRIT_DAMAGE:
			player.combat.crit_damage_multiplier = minf(player.combat.crit_damage_multiplier + float(gear_up.amount) * GEAR_MULT_CRIT_DAMAGE, STAT_CAP_CRIT_DAMAGE)
	player.gear_up_applied.emit(gear_up)
