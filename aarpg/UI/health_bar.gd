class_name HealthBar
extends CanvasLayer

@onready var hearts_container: HBoxContainer = $MarginContainer/VBoxContainer/HeartsContainer
@onready var label: Label = $MarginContainer/VBoxContainer/Label

var hearts: Array[TextureRect] = []

func _ready() -> void:
	var players = get_tree().get_nodes_in_group("player")
	if players.size() > 0:
		var player = players[0] as Player
		player.health_changed.connect(_on_health_changed)
		_setup_hearts(player.max_health)
		_on_health_changed(player.health)

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
