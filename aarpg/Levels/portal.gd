class_name Portal
extends Area2D

@export var target_level_index: int = 1


func _ready() -> void:
	body_entered.connect(_on_body_entered)


func _on_body_entered(body: Node2D) -> void:
	if body is Player:
		AudioManager.play_sfx_from_path("res://assets/audio/sfx/lever_02.wav")
		GameManager.load_level(target_level_index)
