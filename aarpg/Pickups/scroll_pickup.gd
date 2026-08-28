class_name ScrollPickup
extends PickupBase

const DEFAULT_SCROLL = preload("res://aarpg/config/scrolls/xp_scroll.tres")

@export var scroll: Scroll = DEFAULT_SCROLL

@onready var glow: PointLight2D = get_node_or_null("Glow")
@onready var name_label: Label = get_node_or_null("NameLabel")


func _ready() -> void:
	_configure_item_bob(0.8)
	super._ready()
	_apply_visual()


func get_active_scroll() -> Scroll:
	return scroll if scroll != null else DEFAULT_SCROLL


func get_display_name() -> String:
	return get_active_scroll().display_name


func get_scroll_color() -> Color:
	return get_active_scroll().scroll_color


func _apply_visual() -> void:
	queue_redraw()
	if glow:
		glow.color = get_scroll_color()
	if name_label:
		name_label.text = get_display_name()
		name_label.add_theme_color_override("font_color", get_scroll_color())


func _draw() -> void:
	var c := get_scroll_color()
	if get_active_scroll().kind == Scroll.Kind.HYBRID:
		draw_colored_polygon(PackedVector2Array(
			Vector2(0, -7), Vector2(5, -3), Vector2(5, 5), Vector2(0, 7)
		), c.darkened(0.15))
		draw_colored_polygon(PackedVector2Array(
			Vector2(0, -7), Vector2(-5, -3), Vector2(-5, 5), Vector2(0, 7)
		), c)
		draw_line(Vector2(0, -7), Vector2(0, 7), Color.WHITE, 1.2)
		for i in range(2):
			var y := -2 + i * 3
			draw_line(Vector2(2, y), Vector2(4, y), Color.WHITE, 0.8)
			draw_line(Vector2(-2, y), Vector2(-4, y), Color.WHITE, 0.8)
		draw_circle(Vector2(0, -10), 1.8, Color(1.0, 0.9, 0.4))
		draw_circle(Vector2(-3, -10), 1.0, Color(1.0, 0.9, 0.4))
		draw_circle(Vector2(3, -10), 1.0, Color(1.0, 0.9, 0.4))
	elif get_active_scroll().kind == Scroll.Kind.XP_PARCHMENT:
		draw_colored_polygon(PackedVector2Array(
			Vector2(-4, -7), Vector2(4, -7), Vector2(4, 7), Vector2(-4, 7)
		), c.darkened(0.25))
		draw_colored_polygon(PackedVector2Array(
			Vector2(-3, -5), Vector2(3, -5), Vector2(3, 5), Vector2(-3, 5)
		), c)
		draw_circle(Vector2(0, 0), 1.8, Color(0.3, 0.7, 1.0))
		draw_line(Vector2(0, -5), Vector2(0, -7), Color.WHITE, 1.2)
		draw_line(Vector2(0, 5), Vector2(0, 7), Color.WHITE, 1.2)
	else:
		draw_colored_polygon(PackedVector2Array(
			Vector2(0, -6), Vector2(6, -4), Vector2(6, 5), Vector2(0, 6)
		), c.darkened(0.2))
		draw_colored_polygon(PackedVector2Array(
			Vector2(0, -6), Vector2(-6, -4), Vector2(-6, 5), Vector2(0, 6)
		), c)
		draw_line(Vector2(0, -6), Vector2(0, 6), c.darkened(0.4), 1.2)
		for i in range(3):
			var y := -2 + i * 2
			draw_line(Vector2(2, y), Vector2(5, y - 0.5), Color.WHITE, 1.0)
			draw_line(Vector2(-2, y), Vector2(-5, y - 0.5), Color.WHITE, 1.0)
		draw_circle(Vector2(0, -9), 1.6, Color(1.0, 0.95, 0.4))
		draw_line(Vector2(0, -11), Vector2(0, -7), Color.WHITE, 0.8)
		draw_line(Vector2(-2, -9), Vector2(2, -9), Color.WHITE, 0.8)


func _apply_effect(player: Player) -> void:
	var active := get_active_scroll()
	var popup_text := ""
	var popup_color := active.scroll_color
	if active.kind == Scroll.Kind.XP_PARCHMENT:
		_grant_xp(player, active)
		popup_text = "+%d XP" % active.xp_amount
	elif active.kind == Scroll.Kind.HYBRID:
		_grant_xp(player, active)
		_grant_levels(player, active.levels_granted)
		popup_text = "+%d XP & LEVEL UP!" % active.xp_amount
		popup_color = Color(1.0, 0.9, 0.4)
	else:
		_grant_levels(player, active.levels_granted)
		popup_text = "LEVEL UP!"
		popup_color = Color(1.0, 0.9, 0.4)
	_spawn_popup(popup_text, popup_color, Vector2(0, -22))


func _grant_xp(player: Player, active: Scroll) -> void:
	var amount := maxi(active.xp_amount, 0)
	if active.respects_xp_multiplier:
		player.gain_xp(amount)
	else:
		player.gain_xp_flat(amount)


func _grant_levels(player: Player, count: int) -> void:
	for i in range(maxi(count, 1)):
		player.gain_level()
