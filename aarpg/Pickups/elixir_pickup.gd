class_name ElixirPickup
extends PotionPickup

@export var heal_amount: int = 10


func _ready() -> void:
	bob_speed = 3.5
	bob_amplitude = 3.0
	bob_base_y = -7.0
	rotation_speed = 1.2
	lifetime = 20.0
	super._ready()


func _get_visual_color() -> Color:
	return Color(1.0, 0.75, 0.2)


func _get_visual_name() -> String:
	return "Elixir"


func _draw() -> void:
	draw_circle(Vector2.ZERO, 7.0, Color(0.75, 0.5, 0.12))
	draw_circle(Vector2.ZERO, 5.0, Color(1.0, 0.82, 0.35))
	draw_rect(Rect2(-2.0, -11.0, 4.0, 3.0), Color(0.9, 0.85, 0.4))
	draw_rect(Rect2(-3.0, -9.0, 6.0, 2.0), Color(1.0, 0.95, 0.6))
	draw_circle(Vector2(-2, -1), 1.3, Color(1.0, 0.97, 0.75))
	draw_circle(Vector2(2, 1), 1.0, Color(1.0, 0.9, 0.65))