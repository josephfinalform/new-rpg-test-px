class_name PotionPickup
extends PickupBase

const SFX_HEAL = preload("res://assets/audio/sfx/hp_up.wav")

@export var heal_amount: int = 4


func _ready() -> void:
	bob_speed = 3.5
	bob_amplitude = 2.5
	bob_base_y = -6.0
	rotation_speed = 0.8
	lifetime = 15.0
	super._ready()


func _play_collect_feedback() -> void:
	AudioManager.play_sfx(SFX_HEAL)
	var tween := create_tween()
	tween.set_parallel(true)
	tween.tween_property(self, "modulate:a", 0.0, 0.3)
	tween.tween_property(self, "scale", Vector2(1.6, 1.6), 0.25).set_trans(Tween.TRANS_BACK)
	tween.chain().tween_callback(queue_free)


func _draw() -> void:
	draw_circle(Vector2.ZERO, 6.0, Color(0.85, 0.2, 0.45))
	draw_circle(Vector2(0, -1), 4.0, Color(1.0, 0.75, 0.85))
	draw_rect(Rect2(-1.5, -10.0, 3.0, 3.0), Color(1.0, 0.7, 0.8))
	draw_rect(Rect2(-2.5, -8.0, 5.0, 2.0), Color(1.0, 0.9, 0.9))


func _apply_effect(player: Player) -> void:
	player.heal(heal_amount)
