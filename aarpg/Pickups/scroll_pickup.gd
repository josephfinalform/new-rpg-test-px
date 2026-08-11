class_name ScrollPickup
extends Area2D

enum Kind { XP_PARCHMENT, LEVEL_TOME }

const XP_POPUP = preload("res://aarpg/Effects/floating_text.tscn")

@export var kind: Kind = Kind.XP_PARCHMENT
@export var xp_amount: int = -1

var collected: bool = false
var _bob_time: float = 0.0

@onready var glow: PointLight2D = get_node_or_null("Glow")
@onready var name_label: Label = get_node_or_null("NameLabel")


func _ready() -> void:
	body_entered.connect(_on_body_entered)
	_apply_visual()


func _process(delta: float) -> void:
	_bob_time += delta
	position.y += sin(_bob_time * 3.0) * delta * 2.0
	rotation += delta * 0.8


func get_display_name() -> String:
	return "XP Scroll" if kind == Kind.XP_PARCHMENT else "Level Tome"


func get_scroll_color() -> Color:
	return Color(0.85, 0.75, 0.55) if kind == Kind.XP_PARCHMENT else Color(1.0, 0.85, 0.4)


func _apply_visual() -> void:
	queue_redraw()
	if glow:
		glow.color = get_scroll_color()
	if name_label:
		name_label.text = get_display_name()
		name_label.add_theme_color_override("font_color", get_scroll_color())


func _draw() -> void:
	var c := get_scroll_color()
	if kind == Kind.XP_PARCHMENT:
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


func _on_body_entered(body: Node2D) -> void:
	if collected or not body is Player:
		return
	var player := body as Player
	if player.is_dead:
		return
	collected = true
	set_deferred("monitoring", false)
	var popup_text := ""
	var popup_color := get_scroll_color()
	if kind == Kind.XP_PARCHMENT:
		var amount := xp_amount if xp_amount > 0 else player.level_config.parchment_xp
		player.gain_xp(amount)
		popup_text = "+%d XP" % amount
	else:
		var levels := maxi(player.level_config.tome_levels, 1)
		for i in range(levels):
			player.gain_level()
		popup_text = "LEVEL UP!"
		popup_color = Color(1.0, 0.9, 0.4)
	var popup := XP_POPUP.instantiate() as Label
	get_parent().add_child(popup)
	popup.text = popup_text
	popup.modulate = popup_color
	popup.global_position = global_position + Vector2(0, -22)
	AudioManager.play_sfx_from_path("res://assets/audio/sfx/item_pickup.wav")
	var tween := create_tween()
	tween.set_parallel(true)
	tween.tween_property(self, "modulate:a", 0.0, 0.3)
	tween.chain().tween_callback(queue_free)
