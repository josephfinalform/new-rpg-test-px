class_name WeaponPickup
extends PickupBase

@export var weapon: Weapon


func _ready() -> void:
	_configure_item_bob(1.2)
	super._ready()
	_apply_visual()


func _get_visual_color() -> Color:
	return weapon.trail_color if weapon else Color.WHITE


func _get_visual_name() -> String:
	return weapon.display_name if weapon else ""


func _apply_visual() -> void:
	if weapon == null:
		return
	_sync_visual_components()


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
