class_name HeartPickup
extends PickupBase

@export var heal_amount: int = 1


func _ready() -> void:
	bob_speed = 4.0
	bob_amplitude = 2.0
	bob_base_y = -4.0
	sfx_path = "res://assets/audio/sfx/hp_up.wav"
	lifetime = 12.0
	super._ready()


func _draw() -> void:
	draw_circle(Vector2.ZERO, 7.0, Color(0.95, 0.25, 0.35))
	draw_circle(Vector2(0, -2), 5.0, Color(1.0, 0.65, 0.7))


func _apply_effect(player: Player) -> void:
	player.heal(heal_amount)
