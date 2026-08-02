class_name Level
extends Node2D

@export var player_spawn: Vector2 = Vector2(64, 64)
@export var is_final_level: bool = false
@export var boss: NodePath


func _ready() -> void:
	var player := _get_player()
	if player:
		player.died.connect(_on_player_died)
		player.global_position = player_spawn
	if not boss.is_empty():
		var boss_node := get_node_or_null(boss)
		if boss_node:
			boss_node.died.connect(_on_boss_died)
	if is_final_level:
		_show_boss_banner()


func _show_boss_banner() -> void:
	var overlay := CanvasLayer.new()
	overlay.layer = 10
	add_child(overlay)
	var label := Label.new()
	label.text = "WIZARD BOSS"
	label.add_theme_font_size_override("font_size", 28)
	label.add_theme_color_override("font_color", Color(1, 0.3, 0.3))
	label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	label.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	label.modulate.a = 0.0
	overlay.add_child(label)
	var tween := label.create_tween()
	tween.tween_property(label, "modulate:a", 1.0, 0.5)
	tween.tween_interval(1.2)
	tween.tween_property(label, "modulate:a", 0.0, 0.5)
	await tween.finished
	overlay.queue_free()


func _get_player() -> Player:
	var players := get_tree().get_nodes_in_group("player")
	if players.size() > 0:
		return players[0] as Player
	return null


func _on_player_died() -> void:
	await get_tree().create_timer(1.2).timeout
	GameManager.restart_current_level()


func _on_boss_died() -> void:
	if is_final_level:
		_show_victory()


func _show_victory() -> void:
	var overlay := CanvasLayer.new()
	overlay.layer = 10
	add_child(overlay)
	var label := Label.new()
	label.text = "VICTORY!"
	label.add_theme_font_size_override("font_size", 36)
	label.add_theme_color_override("font_color", Color(1.0, 0.84, 0.0))
	label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	label.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	overlay.add_child(label)
	await get_tree().create_timer(3.0).timeout
	GameManager.start_game()
