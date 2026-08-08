class_name GearUpPickup
extends Area2D

const XP_POPUP = preload("res://aarpg/Effects/floating_text.tscn")

@export var gear_up: GearUp

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
	rotation += delta * 0.6


func _apply_visual() -> void:
	if gear_up == null:
		return
	queue_redraw()
	if glow:
		glow.color = gear_up.stat_color
	if name_label:
		name_label.text = gear_up.display_name
		name_label.add_theme_color_override("font_color", gear_up.stat_color)


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


func _on_body_entered(body: Node2D) -> void:
	if collected or not body is Player or gear_up == null:
		return
	var player := body as Player
	if player.is_dead:
		return
	collected = true
	set_deferred("monitoring", false)
	player.apply_gear_up(gear_up)
	var popup := XP_POPUP.instantiate() as Label
	get_parent().add_child(popup)
	popup.text = gear_up.display_name + "!"
	popup.modulate = gear_up.stat_color
	popup.global_position = global_position + Vector2(0, -22)
	AudioManager.play_sfx_from_path("res://assets/audio/sfx/item_pickup.wav")
	var tween := create_tween()
	tween.set_parallel(true)
	tween.tween_property(self, "modulate:a", 0.0, 0.3)
	tween.chain().tween_callback(queue_free)
