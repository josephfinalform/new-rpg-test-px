class_name HealthBar
extends CanvasLayer

@onready var hearts_container: HBoxContainer = $MarginContainer/VBoxContainer/HeartsContainer
@onready var label: Label = $MarginContainer/VBoxContainer/Label
@onready var xp_bar: ProgressBar = $MarginContainer/VBoxContainer/XPBar
@onready var level_label: Label = $MarginContainer/VBoxContainer/LevelLabel
@onready var rank_label: Label = get_node_or_null("MarginContainer/VBoxContainer/RankLabel")
@onready var level_name_label: Label = get_node_or_null("MarginContainer/VBoxContainer/LevelNameLabel")
@onready var weapon_label: Label = get_node_or_null("MarginContainer/VBoxContainer/WeaponLabel")
@onready var armor_label: Label = get_node_or_null("MarginContainer/VBoxContainer/ArmorLabel")
@onready var gear_up_label: Label = get_node_or_null("MarginContainer/VBoxContainer/GearUpLabel")
@onready var season_label: Label = get_node_or_null("MarginContainer/VBoxContainer/SeasonLabel")
@onready var kills_label: Label = get_node_or_null("MarginContainer/VBoxContainer/KillsLabel")
@onready var xp_text_label: Label = get_node_or_null("MarginContainer/VBoxContainer/XPTextLabel")

var hearts: Array[TextureRect] = []
var _xp_tween: Tween = null

func _ready() -> void:
	var players = get_tree().get_nodes_in_group("player")
	if players.size() > 0:
		var player = players[0] as Player
		player.health_changed.connect(_on_health_changed)
		player.xp_changed.connect(_on_xp_changed)
		player.level_up.connect(_on_level_up)
		player.prestige_changed.connect(_on_prestige_changed)
		player.weapon_changed.connect(_on_weapon_changed)
		player.armor_changed.connect(_on_armor_changed)
		player.gear_up_applied.connect(_on_gear_up_applied)
		_setup_hearts(player.max_health)
		_on_health_changed(player.health)
		_on_xp_changed(player.xp, player.level)
		_on_level_up(player.level)
		if player.equipped_weapon:
			_on_weapon_changed(player.equipped_weapon)
		if player.equipped_armor:
			_on_armor_changed(player.equipped_armor)
	GameManager.level_changed.connect(_on_level_changed)
	_on_level_changed(GameManager.current_level_index)
	GameManager.kills_changed.connect(_on_kills_changed)
	_on_kills_changed(GameManager.kills)
	SeasonManager.season_changed.connect(_on_season_changed)
	_on_season_changed(SeasonManager.current_season)

func _on_level_changed(index: int) -> void:
	if level_name_label:
		level_name_label.text = GameManager.get_level_name(index)

func _on_kills_changed(total: int) -> void:
	if kills_label:
		kills_label.text = "Kills: " + str(total)

func _on_weapon_changed(weapon: Weapon) -> void:
	if weapon_label:
		weapon_label.text = weapon.display_name
		weapon_label.add_theme_color_override("font_color", weapon.trail_color)

func _on_armor_changed(armor: Armor) -> void:
	if armor_label:
		var text := armor.display_name
		if armor.xp_multiplier != 1.0:
			text += "  (XP x%s)" % str(armor.xp_multiplier)
		armor_label.text = text
		armor_label.add_theme_color_override("font_color", armor.armor_color)

func _on_gear_up_applied(gear_up: GearUp) -> void:
	if gear_up_label:
		gear_up_label.text = gear_up.display_name
		gear_up_label.add_theme_color_override("font_color", gear_up.stat_color)
		gear_up_label.modulate.a = 1.0
		var tween := gear_up_label.create_tween()
		tween.tween_interval(2.0)
		tween.tween_property(gear_up_label, "modulate:a", 0.0, 0.5)

func _on_season_changed(season: int) -> void:
	if season_label:
		season_label.text = SeasonManager.get_season_name()
		season_label.add_theme_color_override("font_color", SeasonManager.get_outdoor_tint())

func _setup_hearts(max_hp: int) -> void:
	for child in hearts_container.get_children():
		child.queue_free()
	hearts.clear()
	for i in range(max_hp):
		var heart = TextureRect.new()
		heart.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
		heart.custom_minimum_size = Vector2(12, 12)
		hearts.append(heart)
		hearts_container.add_child(heart)

func _on_health_changed(new_health: int) -> void:
	for i in range(hearts.size()):
		if i < new_health:
			hearts[i].modulate = Color.RED
		else:
			hearts[i].modulate = Color(0.3, 0.3, 0.3)

func _on_xp_changed(new_xp: int, _new_level: int) -> void:
	var players = get_tree().get_nodes_in_group("player")
	if players.size() > 0:
		var player = players[0] as Player
		if player.level >= player.level_config.max_level:
			xp_bar.max_value = float(player.level_config.prestige_xp_threshold)
			if xp_text_label:
				xp_text_label.text = "★ %d / %d" % [player.prestige_xp, player.level_config.prestige_xp_threshold]
		else:
			xp_bar.max_value = player.xp_to_next_level
			if xp_text_label:
				xp_text_label.text = str(new_xp) + " / " + str(player.xp_to_next_level)
		if _xp_tween and _xp_tween.is_valid():
			_xp_tween.kill()
		_xp_tween = create_tween()
		_xp_tween.tween_property(xp_bar, "value", float(new_xp), 0.25).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)

func _on_level_up(new_level: int) -> void:
	_update_level_label()
	var tween := level_label.create_tween()
	tween.tween_property(level_label, "scale", Vector2(1.7, 1.7), 0.15).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	tween.tween_property(level_label, "scale", Vector2(1.0, 1.0), 0.3).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_IN)
	tween.tween_callback(func() -> void: level_label.add_theme_color_override("font_color", Color.WHITE))
	_update_rank(new_level)

func _on_prestige_changed(_prestige: int) -> void:
	_update_level_label()
	var players = get_tree().get_nodes_in_group("player")
	if players.size() > 0:
		_update_rank((players[0] as Player).level)
	if level_label:
		level_label.add_theme_color_override("font_color", Color(1.0, 0.9, 0.4))

func _update_level_label() -> void:
	var players = get_tree().get_nodes_in_group("player")
	if players.size() == 0:
		return
	var player = players[0] as Player
	var text := "Lv." + str(player.level)
	if player.prestige > 0:
		text += "  ★" + str(player.prestige)
	level_label.text = text
	level_label.add_theme_color_override("font_color", Color(1, 0.9, 0.3) if player.prestige > 0 else Color.WHITE)

func _update_rank(new_level: int) -> void:
	if not rank_label:
		return
	var players = get_tree().get_nodes_in_group("player")
	if players.size() == 0:
		return
	var player = players[0] as Player
	var title := player.get_rank_title()
	var stars := player.level_config.get_prestige_title(player.prestige)
	if not stars.is_empty():
		title += "  " + stars
	rank_label.text = title
	rank_label.add_theme_color_override("font_color", player.get_rank_color())
