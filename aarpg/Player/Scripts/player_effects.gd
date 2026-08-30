class_name PlayerEffectsHandler
extends RefCounted

const LEVEL_UP_EFFECT = preload("res://aarpg/Effects/level_up_effect.tscn")
const DAMAGE_NUMBER = preload("res://aarpg/Effects/damage_number.tscn")
const CRIT_POPUP = preload("res://aarpg/Effects/floating_text.tscn")

var player: Player


func _init(p: Player) -> void:
	player = p


func spawn_damage_number(amount: int) -> void:
	_spawn_popup(DAMAGE_NUMBER, str(amount), Color(1.0, 0.35, 0.35), Vector2(randf_range(-6, 6), -16))


func spawn_crit_text(enemy: Node2D) -> void:
	_spawn_popup(CRIT_POPUP, "CRIT!", Color(1.0, 0.9, 0.3), enemy.global_position + Vector2(randf_range(-6, 6), -18) - player.global_position)


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
	_spawn_popup(CRIT_POPUP, "COMBO x%d!" % count, Color(1.0, 0.6, 0.2), Vector2(0, -24))


func spawn_season_banner(text: String) -> void:
	var overlay := CanvasLayer.new()
	overlay.layer = 20
	get_tree_current_scene().add_child(overlay)
	var label := Label.new()
	label.text = text
	label.add_theme_font_size_override("font_size", 18)
	label.add_theme_color_override("font_color", Color(0.6, 1.0, 0.7))
	label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	label.set_anchors_and_offsets_preset(Control.PRESET_CENTER_TOP)
	label.offset_top += 70
	label.modulate.a = 0.0
	overlay.add_child(label)
	var tween := label.create_tween()
	tween.tween_property(label, "modulate:a", 1.0, 0.25)
	tween.tween_interval(1.6)
	tween.tween_property(label, "modulate:a", 0.0, 0.5)
	tween.tween_callback(overlay.queue_free)


func _spawn_popup(scene: PackedScene, text: String, color: Color, offset: Vector2) -> Label:
	var popup := scene.instantiate() as Label
	get_tree_current_scene().add_child(popup)
	popup.text = text
	popup.modulate = color
	popup.global_position = player.global_position + offset
	return popup


func get_tree_current_scene() -> Node:
	return player.get_tree().current_scene
