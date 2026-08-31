class_name GoldPickup
extends PickupBase

const SFX_GOLD = preload("res://assets/audio/sfx/item_pickup.wav")

@export var gold_amount: int = 1
@export var magnetization: bool = true


func _ready() -> void:
	bob_speed = 5.0
	bob_amplitude = 2.0
	bob_base_y = -4.0
	rotation_speed = 1.8
	lifetime = 15.0
	super._ready()


func _draw() -> void:
	draw_circle(Vector2.ZERO, 5.0, Color(0.95, 0.78, 0.15))
	draw_circle(Vector2.ZERO, 3.0, Color(1.0, 0.9, 0.45))
	draw_circle(Vector2(0, 0), 1.2, Color(0.6, 0.45, 0.05))


func _play_collect_feedback() -> void:
	AudioManager.play_sfx(SFX_GOLD)
	super._play_collect_feedback()


func _apply_effect(_player: Player) -> void:
	GoldManager.grant(gold_amount)
	_spawn_popup("+" + str(gold_amount) + "G", Color(1.0, 0.85, 0.3), Vector2(0, -14))
