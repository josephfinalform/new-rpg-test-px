class_name GearUpPickup
extends PickupBase

@export var gear_up: GearUp


func _ready() -> void:
	_configure_item_bob(0.6)
	super._ready()
	_apply_visual()


func _get_visual_color() -> Color:
	return gear_up.stat_color if gear_up else Color.WHITE


func _get_visual_name() -> String:
	return gear_up.display_name if gear_up else ""


func _apply_visual() -> void:
	if gear_up == null:
		return
	_sync_visual_components()


func _draw() -> void:
	if gear_up == null:
		return
	var c: Color = gear_up.stat_color
	draw_colored_polygon(PackedVector2Array(
		Vector2(0, -8), Vector2(8, 0), Vector2(0, 8), Vector2(-8, 0)
	), c.darkened(0.3))
	draw_colored_polygon(PackedVector2Array(
		Vector2(0, -4), Vector2(4, 0), Vector2(0, 4), Vector2(-4, 0)
	), c.lerp(Color.WHITE, 0.6))
	match gear_up.stat:
		GearUp.Stat.ATTACK:
			draw_line(Vector2(0, -2), Vector2(0, -7), Color.WHITE, 1.5)
			draw_line(Vector2(-1.5, -5.5), Vector2(1.5, -5.5), Color.WHITE, 1.5)
		GearUp.Stat.MAX_HEALTH:
			draw_line(Vector2(0, -6), Vector2(0, 6), Color.WHITE, 1.5)
			draw_line(Vector2(-4, 0), Vector2(4, 0), Color.WHITE, 1.5)
		GearUp.Stat.SPEED:
			draw_line(Vector2(-3, -5), Vector2(1, 0), Color.WHITE, 1.5)
			draw_line(Vector2(1, 0), Vector2(-3, 5), Color.WHITE, 1.5)
			draw_line(Vector2(1, -5), Vector2(5, 0), Color.WHITE, 1.5)
			draw_line(Vector2(5, 0), Vector2(1, 5), Color.WHITE, 1.5)
		GearUp.Stat.DASH_COOLDOWN:
			draw_circle(Vector2(0, 0), 3.0, Color.WHITE)
			draw_circle(Vector2(0, 0), 1.2, c.darkened(0.2))
			draw_line(Vector2(0, -3), Vector2(0, -6), Color.WHITE, 1.5)
		GearUp.Stat.CRIT_CHANCE:
			for i in range(4):
				var dir := Vector2.RIGHT.rotated(TAU / 4.0 * float(i))
				draw_line(dir * 2.0, dir * 6.0, Color.WHITE, 1.5)
			draw_circle(Vector2(0, 0), 1.4, Color.WHITE)
		GearUp.Stat.LIFESTEAL:
			draw_circle(Vector2(-2.5, -2), 2.2, Color.WHITE)
			draw_circle(Vector2(2.5, -2), 2.2, Color.WHITE)
			draw_colored_polygon(PackedVector2Array(
				Vector2(-5, -0.5), Vector2(5, -0.5), Vector2(0, 6)
			), Color.WHITE)
		GearUp.Stat.XP_BONUS:
			draw_line(Vector2(0, 3), Vector2(0, -2), Color.WHITE, 1.5)
			draw_line(Vector2(-3, 0), Vector2(0, -4), Color.WHITE, 1.5)
			draw_line(Vector2(3, 0), Vector2(0, -4), Color.WHITE, 1.5)
		GearUp.Stat.ARMOR:
			draw_colored_polygon(PackedVector2Array(
				Vector2(0, -7), Vector2(6, -5), Vector2(6, 1), Vector2(3, 5), Vector2(0, 6)
			), Color.WHITE.darkened(0.1))
			draw_colored_polygon(PackedVector2Array(
				Vector2(0, -7), Vector2(-6, -5), Vector2(-6, 1), Vector2(-3, 5), Vector2(0, 6)
			), Color.WHITE.darkened(0.1))
		GearUp.Stat.THORNS:
			var star := PackedVector2Array()
			for i in range(8):
				var a := TAU / 8.0 * float(i)
				var r := 6.5 if i % 2 == 0 else 2.5
				star.append(Vector2.from_angle(a) * r)
			draw_colored_polygon(star, Color.WHITE)
		GearUp.Stat.MAGNET:
			draw_arc(Vector2(0, 4), 4.0, PI, TAU, 16, Color.WHITE, 2.0)
			draw_line(Vector2(-4, 4), Vector2(-4, -2), Color.WHITE, 2.0)
			draw_line(Vector2(4, 4), Vector2(4, -2), Color.WHITE, 2.0)
			draw_line(Vector2(-4, 1), Vector2(-4, 4), Color.RED, 1.0)
			draw_line(Vector2(4, 1), Vector2(4, 4), Color(0.4, 0.6, 1.0), 1.0)
		GearUp.Stat.REGEN:
			draw_circle(Vector2.ZERO, 5.0, Color.WHITE.darkened(0.15))
			draw_line(Vector2(0, -3), Vector2(0, 3), Color.WHITE, 1.5)
			draw_line(Vector2(-3, 0), Vector2(3, 0), Color.WHITE, 1.5)
		GearUp.Stat.FURY:
			draw_polyline(PackedVector2Array(
				Vector2(1, -6), Vector2(-2, -1), Vector2(1, -1), Vector2(-2, 5), Vector2(3, -3), Vector2(0, -3)
			), Color.WHITE, 1.5)
		GearUp.Stat.KNOCKBACK:
			draw_arc(Vector2.ZERO, 5.0, 0.0, PI, 16, Color.WHITE, 1.5)
			draw_line(Vector2(0, 5), Vector2(0, 8), Color.WHITE, 1.5)
			draw_line(Vector2(-2, 7), Vector2(0, 8), Color.WHITE, 1.5)
			draw_line(Vector2(2, 7), Vector2(0, 8), Color.WHITE, 1.5)
		GearUp.Stat.CRIT_DAMAGE:
			for i in range(3):
				var a := -PI / 2.0 + TAU / 3.0 * float(i)
				draw_line(Vector2.from_angle(a) * 2.0, Vector2.from_angle(a) * 6.0, Color.WHITE, 1.5)
			draw_circle(Vector2.ZERO, 1.4, Color.WHITE)


func _apply_effect(player: Player) -> void:
	if gear_up == null:
		return
	player.apply_gear_up(gear_up)
	_spawn_popup(gear_up.display_name + "!", gear_up.stat_color, Vector2(0, -22))
