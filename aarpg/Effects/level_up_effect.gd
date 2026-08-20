class_name LevelUpEffect
extends Node2D

const LEVEL_UP_JINGLE = preload("res://assets/audio/music/level_up_jingle.wav")

@onready var particles: CPUParticles2D = $Burst
@onready var title_label: Label = $CanvasLayer/CenterContainer/VBoxContainer/TitleLabel
@onready var rank_label: Label = $CanvasLayer/CenterContainer/VBoxContainer/RankLabel
@onready var stats_label: Label = $CanvasLayer/CenterContainer/VBoxContainer/StatsLabel


func _ready() -> void:
	AudioManager.play_sfx(LEVEL_UP_JINGLE)
	particles.position = Vector2.ZERO
	particles.amount = 32
	particles.lifetime = 0.7
	particles.one_shot = true
	particles.explosiveness = 1.0
	particles.emitting = true
	particles.direction = Vector2(0, -1)
	particles.spread = 180.0
	particles.gravity = Vector2(0, 40)
	particles.initial_velocity_min = 40.0
	particles.initial_velocity_max = 110.0
	particles.scale_amount_min = 1.0
	particles.scale_amount_max = 2.5
	var tween := create_tween()
	tween.set_parallel(true)
	tween.tween_property(title_label, "scale", Vector2(1.3, 1.3), 0.35).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	tween.tween_property(title_label, "modulate:a", 0.0, 0.5).set_delay(0.9)
	tween.tween_property(rank_label, "modulate:a", 0.0, 0.5).set_delay(0.95)
	tween.tween_property(stats_label, "modulate:a", 0.0, 0.5).set_delay(1.0)
	tween.chain().tween_callback(queue_free)


func setup(stats_text: String, rank_title: String = "", rank_color: Color = Color.WHITE) -> void:
	if not rank_title.is_empty():
		rank_label.text = rank_title
		rank_label.add_theme_color_override("font_color", rank_color)
		rank_label.visible = true
	if not stats_text.is_empty():
		stats_label.text = stats_text
		stats_label.visible = true
