extends RefCounted

const HEART_SCENE = preload("res://aarpg/Pickups/heart_pickup.tscn")
const XP_GEM_SCENE = preload("res://aarpg/Pickups/xp_gem.tscn")
const POTION_SCENE = preload("res://aarpg/Pickups/potion_pickup.tscn")
const GOLD_SCENE = preload("res://aarpg/Pickups/gold_pickup.tscn")
const XP_POPUP = preload("res://aarpg/Effects/floating_text.tscn")


func spawn_kill_rolls(owner: Enemy) -> void:
	var drop_luck := GameManager.get_drop_luck()
	_roll_drop(owner, owner.heart_drop_chance, HEART_SCENE, drop_luck)
	_roll_drop(owner, owner.xp_gem_drop_chance, XP_GEM_SCENE, drop_luck)
	_roll_drop(owner, owner.potion_drop_chance, POTION_SCENE, drop_luck)
	if owner.gold_drop_chance > 0.0 and randf() < minf(owner.gold_drop_chance * drop_luck, 1.0):
		_spawn_gold_drop(owner, drop_luck)
	if owner.xp_popup_enabled:
		_spawn_xp_popup(owner)


func _roll_drop(owner: Enemy, chance: float, scene: PackedScene, luck: float = 1.0) -> void:
	if chance > 0.0 and randf() < minf(chance * luck, 1.0):
		_spawn_scene(owner, scene, Vector2(randf_range(-8, 8), -4.0))


func _spawn_scene(owner: Enemy, scene: PackedScene, offset: Vector2) -> Node2D:
	var node := scene.instantiate()
	owner.get_parent().add_child(node)
	node.global_position = owner.global_position + offset
	return node


func _spawn_gold_drop(owner: Enemy, drop_luck: float) -> void:
	var gold := GOLD_SCENE.instantiate() as GoldPickup
	owner.get_parent().add_child(gold)
	gold.global_position = owner.global_position + Vector2(randf_range(-8, 8), -4.0)
	gold.gold_amount = maxi(roundi(float(owner.gold_drop_amount) * drop_luck), 1)


func _spawn_xp_popup(owner: Enemy) -> void:
	var popup := _spawn_scene(owner, XP_POPUP, Vector2(0, -14)) as Label
	popup.text = "+" + str(owner.xp_reward)