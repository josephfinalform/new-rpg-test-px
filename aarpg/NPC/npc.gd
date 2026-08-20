class_name NPC
extends Area2D

@export var npc_name: String = "Villager"
@export var dialogue: Dialogue
@export var npc_color: Color = Color(0.85, 0.85, 0.92)

var player_in_range: bool = false

@onready var name_label: Label = get_node_or_null("NameLabel")
@onready var prompt_label: Label = get_node_or_null("PromptLabel")


func _ready() -> void:
	body_entered.connect(_on_body_entered)
	body_exited.connect(_on_body_exited)
	if name_label:
		name_label.text = npc_name
		name_label.add_theme_color_override("font_color", npc_color)
	if prompt_label:
		prompt_label.visible = false
	DialogueManager.register_npc(self)


func _exit_tree() -> void:
	if DialogueManager and is_instance_valid(DialogueManager):
		DialogueManager.unregister_npc(self)


func _process(_delta: float) -> void:
	if prompt_label:
		prompt_label.visible = player_in_range and DialogueManager.active_dialogue == null


func _draw() -> void:
	draw_circle(Vector2(0, 3), 7.0, npc_color.darkened(0.3))
	draw_circle(Vector2(0, -7), 5.0, Color(0.95, 0.87, 0.72))
	draw_circle(Vector2(-1.8, -8), 0.9, Color(0.2, 0.2, 0.28))
	draw_circle(Vector2(1.8, -8), 0.9, Color(0.2, 0.2, 0.28))
	draw_arc(Vector2(0, -3.5), 2.4, 0.15 * PI, 0.85 * PI, 8, npc_color.darkened(0.5), 0.8)


func has_dialogue() -> bool:
	return dialogue != null and dialogue.lines.size() > 0


func _on_body_entered(body: Node2D) -> void:
	if body is Player:
		player_in_range = true


func _on_body_exited(body: Node2D) -> void:
	if body is Player:
		player_in_range = false
