class_name HealthBar
extends CanvasLayer

@onready var hearts_container: HBoxContainer = $MarginContainer/VBoxContainer/HeartsContainer
@onready var label: Label = $MarginContainer/VBoxContainer/Label
@onready var xp_bar: ProgressBar = $MarginContainer/VBoxContainer/XPBar
@onready var level_label: Label = $MarginContainer/VBoxContainer/LevelLabel
@onready var level_name_label: Label = get_node_or_null("MarginContainer/VBoxContainer/LevelNameLabel")

var hearts: Array[TextureRect] = []

func _ready() -> void:
	var players = get_tree().get_nodes_in_group("player")
	if players.size() > 0:
		var player = players[0] as Player
		player.health_changed.connect(_on_health_changed)
		player.xp_changed.connect(_on_xp_changed)
		player.level_up.connect(_on_level_up)
		_setup_hearts(player.max_health)
		_on_health_changed(player.health)
		_on_xp_changed(player.xp, player.level)
		_on_level_up(player.level)
	GameManager.level_changed.connect(_on_level_changed)
	_on_level_changed(GameManager.current_level_index)

func _on_level_changed(index: int) -> void:
	if level_name_label:
		level_name_label.text = GameManager.get_level_name(index)

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
		xp_bar.max_value = player.xp_to_next_level
		xp_bar.value = new_xp

func _on_level_up(new_level: int) -> void:
	level_label.text = "Lv." + str(new_level)
