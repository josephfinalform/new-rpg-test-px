extends Node2D

const MENU_MUSIC = preload("res://assets/audio/music/dungeon_discovery.wav")

@onready var title_label: Label = $CanvasLayer2/CenterContainer/VBoxContainer/TitleLabel
@onready var subtitle_label: Label = $CanvasLayer2/CenterContainer/VBoxContainer/SubtitleLabel
@onready var sword_pivot: Node2D = $SwordPivot
@onready var sparks: CPUParticles2D = $CanvasLayer/Sparks

var _time: float = 0.0


func _ready() -> void:
	_spawn_ground_particles()
	_play_menu_music()
	_setup_title_tween()


func _process(delta: float) -> void:
	_time += delta
	sword_pivot.rotation = sin(_time * 1.4) * 0.15
	sword_pivot.position.x = sin(_time * 0.6) * 12.0
	var pulse := 0.5 + 0.5 * sin(_time * 3.0)
	title_label.modulate = Color(0.65, 0.9, 1.0, 0.85 + 0.15 * pulse)
	subtitle_label.modulate.a = 0.6 + 0.4 * pulse


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_accept"):
		_start_game()


func _on_start_button_pressed() -> void:
	_start_game()


func _start_game() -> void:
	if not GameManager:
		return
	AudioManager.play_sfx_from_path("res://assets/audio/sfx/lever_01.wav")
	GameManager.start_game()


func _play_menu_music() -> void:
	AudioManager.play_music(MENU_MUSIC, 1.5)


func _setup_title_tween() -> void:
	var tween := create_tween()
	tween.set_loops()
	tween.tween_property(title_label, "scale", Vector2(1.08, 1.08), 1.0).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	tween.tween_property(title_label, "scale", Vector2(1.0, 1.0), 1.0).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)


func _spawn_ground_particles() -> void:
	if sparks == null:
		return
	sparks.emitting = true
