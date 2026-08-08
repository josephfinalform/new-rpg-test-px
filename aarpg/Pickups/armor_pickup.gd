class_name ArmorPickup
extends Area2D

const XP_POPUP = preload("res://aarpg/Effects/floating_text.tscn")

@export var armor: Armor

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


func _apply_visual() -> void:
	if armor == null:
		return
	queue_redraw()
	if glow:
		glow.color = armor.armor_color
	if name_label:
		name_label.text = armor.display_name
		name_label.add_theme_color_override("font_color", armor.armor_color)


func _draw() -> void:
	if armor == null:
		return
	var c: Color = armor.armor_color
	var shield := PackedVector2Array(
		Vector2(0, -9), Vector2(8, -6), Vector2(9, 0), Vector2(8, 6),
		Vector2(4, 9), Vector2(-4, 9), Vector2(-8, 6), Vector2(-9, 0), Vector2(-8, -6)
	)
	draw_colored_polygon(shield, c.darkened(0.35))
	draw_colored_polygon(PackedVector2Array(
		Vector2(0, -5), Vector2(4.5, -3), Vector2(5, 0), Vector2(4.5, 3),
		Vector2(2, 4.5), Vector2(-2, 4.5), Vector2(-4.5, 3), Vector2(-5, 0), Vector2(-4.5, -3)
	), c.lerp(Color.WHITE, 0.55))
	draw_circle(Vector2(0, 0), 1.6, Color(0.95, 0.95, 0.9))


func _on_body_entered(body: Node2D) -> void:
	if collected or not body is Player or armor == null:
		return
	var player := body as Player
	if player.is_dead:
		return
	collected = true
	set_deferred("monitoring", false)
	player.equip_armor(armor)
	var popup := XP_POPUP.instantiate() as Label
	get_parent().add_child(popup)
	popup.text = armor.display_name + "!"
	popup.modulate = armor.armor_color
	popup.global_position = global_position + Vector2(0, -22)
	AudioManager.play_sfx_from_path("res://assets/audio/sfx/item_pickup.wav")
	var tween := create_tween()
	tween.set_parallel(true)
	tween.tween_property(self, "modulate:a", 0.0, 0.3)
	tween.chain().tween_callback(queue_free)
