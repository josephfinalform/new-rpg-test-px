class_name PlayerCombatHandler
extends RefCounted

var player: Player

var base_attack_damage: int = 1
var base_attack_cooldown: float = 0.4
var equipped_weapon: Weapon = null
var hit_enemies_this_attack: Array[Node2D] = []

var crit_chance: float = 0.0
var lifesteal: float = 0.0
var crit_damage_multiplier: float = 2.0
var knockback_multiplier: float = 1.0
var attack_speed_multiplier: float = 1.0
var thorns_damage: int = 0
var gear_armor_reduction: int = 0


func _init(p: Player) -> void:
	player = p


func process_hitbox_body_entered(body: Node2D) -> void:
	if body is Enemy and not body in hit_enemies_this_attack:
		hit_enemies_this_attack.append(body)
		var enemy := body as Enemy
		var dmg := player.attack_damage
		var is_crit := false
		if crit_chance > 0.0 and randf() < crit_chance:
			dmg = maxi(roundi(dmg * crit_damage_multiplier), dmg)
			is_crit = true
		enemy.knockback_multiplier = knockback_multiplier
		enemy.take_damage(dmg, player.global_position, player)
		if is_crit:
			player._spawn_crit_text(enemy)
		if lifesteal > 0.0:
			player.heal(maxi(roundi(dmg * lifesteal), 1))
		if equipped_weapon and equipped_weapon.effect != Weapon.Effect.NONE and enemy.has_method("apply_status_from_weapon"):
			enemy.apply_status_from_weapon(equipped_weapon)
		if player.attack_sfx:
			AudioManager.play_sfx(player.attack_sfx)


func apply_weapon() -> void:
	if equipped_weapon == null:
		return
	player.attack_damage = base_attack_damage + equipped_weapon.damage_bonus
	player.attack_cooldown = base_attack_cooldown * equipped_weapon.cooldown_multiplier * attack_speed_multiplier
	player.attack_timer.wait_time = player.attack_cooldown
	if player.sword_visual:
		player.sword_visual.color = equipped_weapon.trail_color


func equip_weapon(weapon: Weapon) -> void:
	equipped_weapon = weapon
	player.equipped_weapon = weapon
	GameManager.equipped_weapon = weapon
	apply_weapon()
	player.weapon_changed.emit(weapon)


func apply_damage_reduction(incoming: int) -> int:
	var final_amount := incoming
	if player.equipped_armor:
		final_amount = maxi(final_amount - player.equipped_armor.damage_reduction - gear_armor_reduction, 1)
		final_amount = maxi(roundi(final_amount * (1.0 - player.equipped_armor.damage_reduction_ratio)), 1)
	else:
		final_amount = maxi(final_amount - gear_armor_reduction, 1)
	return final_amount
