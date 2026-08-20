class_name PlayerEffectsHandler
extends RefCounted

const LEVEL_UP_EFFECT = preload("res://aarpg/Effects/level_up_effect.tscn")
const DAMAGE_NUMBER = preload("res://aarpg/Effects/damage_number.tscn")
const CRIT_POPUP = preload("res://aarpg/Effects/floating_text.tscn")

var player: Player


func _init(p: Player) -> void:
	player = p


func spawn_damage_number(amount: int) -> void:
	var number := DAMAGE_NUMBER.instantiate() as Label
	get_tree_current_scene().add_child(number)
	number.text = str(amount)
	number.modulate = Color(1.0, 0.35, 0.35)
	number.global_position = player.global_position + Vector2(randf_range(-6, 6), -16)


func spawn_crit_text(enemy: Node2D) -> void:
	var popup := CRIT_POPUP.instantiate() as Label
	get_tree_current_scene().add_child(popup)
	popup.text = "CRIT!"
	popup.modulate = Color(1.0, 0.9, 0.3)
	popup.global_position = enemy.global_position + Vector2(randf_range(-6, 6), -18)


func spawn_level_up_effect() -> void:
	var effect := LEVEL_UP_EFFECT.instantiate()
	get_tree_current_scene().add_child(effect)
	effect.global_position = player.global_position
	var config := player.level_config
	var stats_text := "HP +%d  ATK +%d  SPD +%d" % [
		config.health_gain_per_level,
		config.damage_gain_per_level,
		int(config.move_speed_gain),
	]
	if player.level % config.milestone_interval == 0:
		stats_text += "  MILESTONE x%d!" % config.get_milestone_tier(player.level)
	var rank_title := player.get_rank_title()
	var stars := config.get_prestige_title(player.prestige)
	if not stars.is_empty():
		rank_title += "  " + stars
	effect.setup(stats_text, rank_title, player.get_rank_color())


func spawn_prestige_effect() -> void:
	var effect := LEVEL_UP_EFFECT.instantiate()
	get_tree_current_scene().add_child(effect)
	effect.global_position = player.global_position
	var config := player.level_config
	var stars := config.get_prestige_title(player.prestige)
	var points_text := "Points: %d available" % player.xp_progression.prestige_points
	effect.setup(points_text, "PRESTIGE " + stars, Color(1.0, 0.9, 0.4))


func spawn_combo_milestone(count: int) -> void:
	var popup := CRIT_POPUP.instantiate() as Label
	get_tree_current_scene().add_child(popup)
	popup.text = "COMBO x%d!" % count
	popup.modulate = Color(1.0, 0.6, 0.2)
	popup.global_position = player.global_position + Vector2(0, -24)


func get_tree_current_scene() -> Node:
	return player.get_tree().current_scene
