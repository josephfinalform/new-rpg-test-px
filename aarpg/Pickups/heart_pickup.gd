class_name HeartPickup
extends PickupBase

const SFX_HEAL = preload("res://assets/audio/sfx/hp_up.wav")

@export var heal_amount: int = 1


func _ready() -> void:
	bob_speed = 4.0
	bob_amplitude = 2.0
	bob_base_y = -4.0
	lifetime = 12.0
	super._ready()


func _draw() -> void:
	draw_circle(Vector2.ZERO, 7.0, Color(0.95, 0.25, 0.35))
	draw_circle(Vector2(0, -2), 5.0, Color(1.0, 0.65, 0.7))


func _play_collect_feedback() -> void:
	AudioManager.play_sfx(SFX_HEAL)
	super._play_collect_feedback()


func _apply_effect(player: Player) -> void:
	player.heal(heal_amount)
