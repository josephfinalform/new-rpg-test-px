class_name WeaponPickup
extends Area2D

const XP_POPUP = preload("res://aarpg/Effects/floating_text.tscn")

@export var weapon: Weapon

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
	rotation += delta * 1.2


func _apply_visual() -> void:
	if weapon == null:
		return
	queue_redraw()
	if glow:
		glow.color = weapon.trail_color
	if name_label:
		name_label.text = weapon.display_name
		name_label.add_theme_color_override("font_color", weapon.trail_color)


func _draw() -> void:
	if weapon == null:
		return
	var c: Color = weapon.trail_color
	draw_rect(Rect2(-10, -1.5, 22, 3), c.lerp(Color.WHITE, 0.5))
	draw_rect(Rect2(-13, -5, 3, 10), c.darkened(0.4))
	draw_circle(Vector2(-12, 0), 3.0, Color(0.95, 0.8, 0.3))


func _on_body_entered(body: Node2D) -> void:
	if collected or not body is Player or weapon == null:
		return
	var player := body as Player
	if player.is_dead:
		return
	collected = true
	set_deferred("monitoring", false)
	player.equip_weapon(weapon)
	var popup := XP_POPUP.instantiate() as Label
	get_parent().add_child(popup)
	popup.text = weapon.display_name + "!"
	popup.modulate = weapon.trail_color
	popup.global_position = global_position + Vector2(0, -22)
	AudioManager.play_sfx_from_path("res://assets/audio/sfx/item_pickup.wav")
	var tween := create_tween()
	tween.set_parallel(true)
	tween.tween_property(self, "modulate:a", 0.0, 0.3)
	tween.chain().tween_callback(queue_free)
