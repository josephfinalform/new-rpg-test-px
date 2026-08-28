class_name WeaponPickup
extends PickupBase

@export var weapon: Weapon

@onready var glow: PointLight2D = get_node_or_null("Glow")
@onready var name_label: Label = get_node_or_null("NameLabel")


func _ready() -> void:
	_configure_item_bob(1.2)
	super._ready()
	_apply_visual()


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


func _apply_effect(player: Player) -> void:
	if weapon == null:
		return
	player.equip_weapon(weapon)
	_spawn_popup(weapon.display_name + "!", weapon.trail_color, Vector2(0, -22))
