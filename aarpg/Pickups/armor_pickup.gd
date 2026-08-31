class_name ArmorPickup
extends PickupBase

@export var armor: Armor


func _ready() -> void:
	_configure_item_bob(0.0)
	super._ready()
	_apply_visual()


func _get_visual_color() -> Color:
	return armor.armor_color if armor else Color.WHITE


func _get_visual_name() -> String:
	return armor.display_name if armor else ""


func _apply_visual() -> void:
	if armor == null:
		return
	_sync_visual_components()


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
	_spawn_popup(armor.display_name + "!", armor.get_rarity_color(), Vector2(0, -22))
