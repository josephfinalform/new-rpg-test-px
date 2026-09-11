class_name XpCrystal
extends XpGem

@export var xp_amount: int = 25


func _get_visual_name() -> String:
	return "XP Crystal"


func _draw() -> void:
	draw_colored_polygon(PackedVector2Array(
		Vector2(0, -8), Vector2(6, 0), Vector2(0, 8), Vector2(-6, 0)
	), Color(0.12, 0.45, 0.95))
	draw_colored_polygon(PackedVector2Array(
		Vector2(0, -4), Vector2(3, 0), Vector2(0, 4), Vector2(-3, 0)
	), Color(0.6, 0.87, 1.0))
	draw_line(Vector2(0, -8), Vector2(0, 8), Color(0.8, 0.94, 1.0), 1.0)