class_name Level
extends Node2D

@export var player_spawn: Vector2 = Vector2(64, 64)
@export var is_final_level: bool = false
@export var boss: NodePath
@export var boss_gate_portal: NodePath


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
	label.text = _get_boss_banner_text()
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


func _get_boss_banner_text() -> String:
	if not boss.is_empty():
		var boss_node := get_node_or_null(boss)
		if boss_node and boss_node.has_method("get_boss_name"):
			return boss_node.get_boss_name()
	return "BOSS"


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
	elif not boss_gate_portal.is_empty():
		var portal_node := get_node_or_null(boss_gate_portal)
		if portal_node and portal_node.has_method("unlock"):
			portal_node.unlock()
			_show_gate_opened_banner()


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


func _show_gate_opened_banner() -> void:
	var overlay := CanvasLayer.new()
	overlay.layer = 10
	add_child(overlay)
	var label := Label.new()
	label.text = "THE GATE IS OPEN!"
	label.add_theme_font_size_override("font_size", 22)
	label.add_theme_color_override("font_color", Color(0.6, 1.0, 0.6))
	label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	label.vertical_alignment = VERTICAL_ALIGNMENT_BOTTOM
	label.set_anchors_and_offsets_preset(Control.PRESET_CENTER_BOTTOM)
	label.offset_bottom = -40
	label.modulate.a = 0.0
	overlay.add_child(label)
	var tween := label.create_tween()
	tween.tween_property(label, "modulate:a", 1.0, 0.4)
	tween.tween_interval(1.5)
	tween.tween_property(label, "modulate:a", 0.0, 0.5)
	await tween.finished
	overlay.queue_free()
