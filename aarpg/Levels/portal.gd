class_name Portal
extends Area2D

@export var target_level_index: int = 1
@export var locked: bool = false

var is_open: bool = true

@onready var glow: PointLight2D = get_node_or_null("Glow")


func _ready() -> void:
	body_entered.connect(_on_body_entered)
	is_open = not locked
	_apply_visual_state()


func unlock() -> void:
	if is_open:
		return
	locked = false
	is_open = true
	_apply_visual_state()
	AudioManager.play_sfx_from_path("res://assets/audio/sfx/lever_02.wav")


func _apply_visual_state() -> void:
	modulate = Color.WHITE if is_open else Color(0.3, 0.3, 0.35)
	if glow:
		glow.enabled = is_open
		glow.energy = 2.2 if is_open else 0.0


func _on_body_entered(body: Node2D) -> void:
	if not body is Player:
		return
	if not is_open:
		AudioManager.play_sfx_from_path("res://assets/audio/sfx/locked_door.wav")
		return
	AudioManager.play_sfx_from_path("res://assets/audio/sfx/lever_02.wav")
	GameManager.load_level(target_level_index)
