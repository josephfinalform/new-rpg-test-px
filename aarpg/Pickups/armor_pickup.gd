class_name ArmorPickup
extends PickupBase

@export var armor: Armor

@onready var glow: PointLight2D = get_node_or_null("Glow")
@onready var name_label: Label = get_node_or_null("NameLabel")


func _ready() -> void:
	bob_speed = 3.0
	bob_amplitude = 2.0
	bob_base_y = 0.0
	super._ready()
	_apply_visual()


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


func _apply_effect(player: Player) -> void:
	if armor == null:
		return
	player.equip_armor(armor)
	_spawn_popup(armor.display_name + "!", armor.armor_color, Vector2(0, -22))
