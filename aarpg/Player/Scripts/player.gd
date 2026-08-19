class_name Player
extends CharacterBody2D

const LEVEL_UP_EFFECT = preload("res://aarpg/Effects/level_up_effect.tscn")
const DAMAGE_NUMBER = preload("res://aarpg/Effects/damage_number.tscn")
const CRIT_POPUP = preload("res://aarpg/Effects/floating_text.tscn")

signal health_changed(new_health: int)
signal died
signal xp_changed(new_xp: int, new_level: int)
signal level_up(new_level: int)
signal prestige_changed(prestige: int)
signal weapon_changed(weapon: Weapon)
signal armor_changed(armor: Armor)
signal gear_up_applied(gear_up: GearUp)

@export var move_speed: float = 100.0
@export var sprint_speed: float = 180.0
@export var max_health: int = 6
@export var attack_damage: int = 1
@export var attack_cooldown: float = 0.4
@export var invincibility_time: float = 1.0
@export var attack_sfx: AudioStream
@export var hurt_sfx: AudioStream
@export var death_sfx: AudioStream
@export var level_up_sfx: AudioStream

@export_group("Dash")
@export var dash_speed: float = 280.0
@export var dash_duration: float = 0.16
@export var dash_cooldown: float = 1.2

var direction: Vector2 = Vector2.ZERO
var facing: Vector2 = Vector2.DOWN
var is_sprinting: bool = false
var health: int = 6
var is_invincible: bool = false
var is_dead: bool = false
var can_attack: bool = true
var hit_enemies_this_attack: Array[Node2D] = []
var is_dashing: bool = false
var dash_velocity: Vector2 = Vector2.ZERO

var base_attack_damage: int = 1
var base_attack_cooldown: float = 0.4
var base_move_speed: float = 100.0
var base_sprint_speed: float = 180.0
var base_dash_cooldown: float = 1.2
var level_move_bonus: float = 0.0
var level_sprint_bonus: float = 0.0
var gear_speed_bonus: float = 0.0
var gear_dash_reduction: float = 0.0
var equipped_weapon: Weapon = null
var equipped_armor: Armor = null

@onready var armor_visual: Polygon2D = get_node_or_null("ArmorVisual")

var xp_progression: XpProgression

var level: int:
	get:
		return xp_progression.level if xp_progression else 1
var xp: int:
	get:
		return xp_progression.xp if xp_progression else 0
var xp_to_next_level: int:
	get:
		return xp_progression.xp_to_next_level if xp_progression else 10
var prestige: int:
	get:
		return xp_progression.prestige if xp_progression else 0
var prestige_xp: int:
	get:
		return xp_progression.prestige_xp if xp_progression else 0

var crit_chance: float = 0.0
var lifesteal: float = 0.0
var xp_bonus: float = 0.0
var gear_armor_reduction: int = 0

var thorns_damage: int = 0
var magnet_radius_bonus: float = 0.0
var regen_per_second: float = 0.0
var attack_speed_multiplier: float = 1.0
var knockback_multiplier: float = 1.0
var crit_damage_multiplier: float = 2.0

var prestige_hp_bonus: int = 0
var prestige_atk_bonus: int = 0
var prestige_spd_bonus: int = 0
var prestige_regen_bonus: float = 0.0
var prestige_lifesteal_bonus: float = 0.0
var prestige_crit_bonus: float = 0.0
var prestige_crit_damage_bonus: float = 0.0
var prestige_dash_reduction_bonus: float = 0.0
var prestige_magnet_bonus: float = 0.0

var level_config: LevelConfig = load("res://aarpg/config/level_config.tres") as LevelConfig

@onready var sprite: Sprite2D = $Sprite2D
@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var state_machine: PlayerStateMachine = $StateMachine
@onready var attack_timer: Timer = $AttackTimer
@onready var invincibility_timer: Timer = $InvincibilityTimer
@onready var hit_flash_timer: Timer = $HitFlashTimer
@onready var hitbox_area: Area2D = $AttackPivot/HitboxArea
@onready var attack_pivot: Node2D = $AttackPivot
@onready var sword_visual: Polygon2D = $AttackPivot/SwordVisual
@onready var dash_timer: Timer = $DashTimer
@onready var dash_cooldown_timer: Timer = $DashCooldownTimer
@onready var regen_timer: Timer = $RegenTimer

func _ready() -> void:
	xp_progression = XpProgression.new(level_config)
	xp_progression.xp_changed.connect(_on_progression_xp_changed)
	xp_progression.level_gained.connect(_on_progression_level_gained)
	xp_progression.prestige_gained.connect(_on_progression_prestige_gained)
	GameManager.combo_milestone.connect(_on_combo_milestone)
	regen_timer.timeout.connect(_on_regen_timer_timeout)
	state_machine.initialize(self)
	health = max_health
	health_changed.emit(health)
	attack_timer.wait_time = attack_cooldown
	invincibility_timer.wait_time = invincibility_time
	dash_timer.wait_time = dash_duration
	dash_cooldown_timer.wait_time = dash_cooldown
	hitbox_area.body_entered.connect(_on_hitbox_body_entered)
	attack_pivot.rotation = 0
	base_attack_damage = attack_damage
	base_attack_cooldown = attack_cooldown
	base_move_speed = move_speed
	base_sprint_speed = sprint_speed
	base_dash_cooldown = dash_cooldown
	var default_weapon := load("res://aarpg/config/weapons/iron_sword.tres") as Weapon
	equipped_weapon = GameManager.equipped_weapon if GameManager.equipped_weapon != null else default_weapon
	_apply_weapon()
	if equipped_armor == null:
		equipped_armor = GameManager.equipped_armor
	_apply_armor_visual()
	_recalculate_speed()
	_apply_dash_cooldown()

func get_input() -> void:
	if is_dead:
		return
	direction = Vector2(
		Input.get_action_strength("right") - Input.get_action_strength("left"),
		Input.get_action_strength("down") - Input.get_action_strength("up")
	)
	if direction != Vector2.ZERO:
		direction = direction.normalized()
		facing = direction

func update_attack_pivot() -> void:
	if facing.x > 0:
		attack_pivot.rotation = 0
		attack_pivot.scale.x = 1
	elif facing.x < 0:
		attack_pivot.rotation = 0
		attack_pivot.scale.x = -1
	elif facing.y > 0:
		attack_pivot.rotation = PI / 2
		attack_pivot.scale.x = 1
	elif facing.y < 0:
		attack_pivot.rotation = -PI / 2
		attack_pivot.scale.x = 1

func play_animation(anim_name: String) -> void:
	if animation_player.current_animation != anim_name:
		animation_player.play(anim_name)

func play_facing_animation(anim_prefix: String, dir: Vector2 = facing) -> void:
	var anim_name: String
	if abs(dir.x) > abs(dir.y):
		anim_name = anim_prefix + "_side"
		sprite.flip_h = dir.x < 0
	elif dir.y > 0:
		anim_name = anim_prefix + "_down"
	else:
		anim_name = anim_prefix + "_up"
	play_animation(anim_name)

func take_damage(amount: int, from_position: Vector2 = global_position, attacker: Node2D = null) -> void:
	if is_invincible or is_dead:
		return
	GameManager.reset_combo()
	if thorns_damage > 0 and attacker is Enemy:
		var enemy := attacker as Enemy
		if not enemy.is_dead:
			enemy.take_damage(thorns_damage, global_position)
	var final_amount := amount
	if equipped_armor:
		final_amount = maxi(final_amount - equipped_armor.damage_reduction - gear_armor_reduction, 1)
		final_amount = maxi(roundi(final_amount * (1.0 - equipped_armor.damage_reduction_ratio)), 1)
	else:
		final_amount = maxi(final_amount - gear_armor_reduction, 1)
	health = max(health - final_amount, 0)
	health_changed.emit(health)
	_spawn_damage_number(final_amount)
	is_invincible = true
	invincibility_timer.start()
	hit_flash_timer.start()
	if hurt_sfx:
		AudioManager.play_sfx(hurt_sfx)
	var knockback_dir = (global_position - from_position).normalized()
	var hurt = state_machine.states["hurt"] as HurtState
	hurt.setup_knockback(knockback_dir)
	state_machine.change_state(hurt)
	if health <= 0:
		_die()

func _die() -> void:
	if is_dead:
		return
	is_dead = true
	can_attack = false
	if death_sfx:
		AudioManager.play_sfx(death_sfx)
	died.emit()
	state_machine.change_state(state_machine.states["death"])

func gain_xp(amount: int) -> void:
	amount = maxi(roundi(amount * get_xp_multiplier()), 1)
	xp_progression.gain_xp(amount)


func gain_xp_flat(amount: int) -> void:
	xp_progression.gain_xp(maxi(amount, 0))


func gain_level() -> void:
	xp_progression.gain_level()


func get_xp_multiplier() -> float:
	var mult := 1.0 + xp_bonus
	if equipped_armor:
		mult *= equipped_armor.xp_multiplier
	mult *= GameManager.get_combo_multiplier()
	mult *= xp_progression.get_xp_multiplier()
	return mult


func _on_progression_xp_changed(current_xp: int, lvl: int) -> void:
	xp_changed.emit(current_xp, lvl)


func _on_progression_prestige_gained(_new_prestige: int) -> void:
	_spawn_prestige_effect()
	prestige_changed.emit(prestige)


func _spawn_prestige_effect() -> void:
	var effect := LEVEL_UP_EFFECT.instantiate()
	get_tree().current_scene.add_child(effect)
	effect.global_position = global_position
	var stars := level_config.get_prestige_title(prestige)
	var points_text := "Points: %d available" % xp_progression.prestige_points
	effect.setup(points_text, "PRESTIGE " + stars, Color(1.0, 0.9, 0.4))


func allocate_prestige_point(tree: LevelConfig.PrestigeTree) -> bool:
	if not xp_progression.allocate_prestige_point(tree):
		return false
	_apply_prestige_tree_bonuses()
	return true


func _apply_prestige_tree_bonuses() -> void:
	var hp_stats: Dictionary = level_config.apply_prestige_point(LevelConfig.PrestigeTree.HP, xp_progression.prestige_tree_hp)
	prestige_hp_bonus = hp_stats.get("max_health", 0)
	prestige_regen_bonus = hp_stats.get("regen", 0.0)
	prestige_lifesteal_bonus = hp_stats.get("lifesteal", 0.0)

	var atk_stats: Dictionary = level_config.apply_prestige_point(LevelConfig.PrestigeTree.ATK, xp_progression.prestige_tree_atk)
	prestige_atk_bonus = atk_stats.get("attack", 0)
	prestige_crit_bonus = atk_stats.get("crit_chance", 0.0)
	prestige_crit_damage_bonus = atk_stats.get("crit_damage", 0.0)

	var spd_stats: Dictionary = level_config.apply_prestige_point(LevelConfig.PrestigeTree.SPD, xp_progression.prestige_tree_spd)
	prestige_spd_bonus = spd_stats.get("speed", 0)
	prestige_dash_reduction_bonus = spd_stats.get("dash_reduction", 0.0)
	prestige_magnet_bonus = spd_stats.get("magnet", 0.0)

	max_health = base_max_health() + prestige_hp_bonus
	health = min(health, max_health)
	_apply_weapon()
	level_move_bonus += prestige_spd_bonus
	level_sprint_bonus += prestige_spd_bonus
	crit_chance = minf(crit_chance + prestige_crit_bonus, 0.5)
	lifesteal = minf(lifesteal + prestige_lifesteal_bonus, 0.5)
	crit_damage_multiplier = minf(crit_damage_multiplier + prestige_crit_damage_bonus, 4.0)
	regen_per_second += prestige_regen_bonus
	gear_dash_reduction += prestige_dash_reduction_bonus
	magnet_radius_bonus += prestige_magnet_bonus
	_apply_dash_cooldown()
	_recalculate_speed()
	health_changed.emit(health)


func base_max_health() -> int:
	var hp := 6
	hp += level_config.health_gain_per_level * (level - 1)
	if level_config.milestone_interval > 0:
		var milestones := (level - 1) / level_config.milestone_interval
		for i in range(1, milestones + 1):
			var mult := maxf(level_config.get_milestone_multiplier(i * level_config.milestone_interval), 1.0)
			hp += maxi(roundi(level_config.milestone_max_health_bonus * mult), 1)
	return hp


func get_prestige_points() -> int:
	return xp_progression.prestige_points


func get_prestige_tree_points(tree: LevelConfig.PrestigeTree) -> int:
	match tree:
		LevelConfig.PrestigeTree.HP:
			return xp_progression.prestige_tree_hp
		LevelConfig.PrestigeTree.ATK:
			return xp_progression.prestige_tree_atk
		LevelConfig.PrestigeTree.SPD:
			return xp_progression.prestige_tree_spd
	return 0

func _on_progression_level_gained(_new_level: int) -> void:
	max_health += level_config.health_gain_per_level
	health = min(health + level_config.heal_on_level_up, max_health)
	base_attack_damage += level_config.damage_gain_per_level
	_apply_weapon()
	level_move_bonus += level_config.move_speed_gain
	level_sprint_bonus += level_config.sprint_speed_gain
	_recalculate_speed()
	_apply_milestone_bonus()
	health_changed.emit(health)
	level_up.emit(level)
	_spawn_level_up_effect()
	_animate_level_scale()

func _apply_milestone_bonus() -> void:
	if level_config.milestone_interval <= 0:
		return
	if level % level_config.milestone_interval != 0:
		return
	var mult := maxf(level_config.get_milestone_multiplier(level), 1.0)
	var hp_bonus := maxi(roundi(level_config.milestone_max_health_bonus * mult), 1)
	var dmg_bonus := maxi(roundi(level_config.milestone_damage_bonus * mult), 1)
	var spd_bonus := level_config.milestone_speed_bonus * mult
	max_health += hp_bonus
	health = min(health + hp_bonus, max_health)
	base_attack_damage += dmg_bonus
	_apply_weapon()
	level_move_bonus += spd_bonus
	level_sprint_bonus += spd_bonus
	_recalculate_speed()

func _spawn_level_up_effect() -> void:
	var effect := LEVEL_UP_EFFECT.instantiate()
	get_tree().current_scene.add_child(effect)
	effect.global_position = global_position
	var stats_text := "HP +%d  ATK +%d  SPD +%d" % [
		level_config.health_gain_per_level,
		level_config.damage_gain_per_level,
		int(level_config.move_speed_gain),
	]
	if level % level_config.milestone_interval == 0:
		stats_text += "  MILESTONE x%d!" % level_config.get_milestone_tier(level)
	var rank_title := get_rank_title()
	var stars := level_config.get_prestige_title(prestige)
	if not stars.is_empty():
		rank_title += "  " + stars
	effect.setup(stats_text, rank_title, get_rank_color())

func _animate_level_scale() -> void:
	var target_scale := minf(1.0 + 0.03 * float(level), 1.5)
	create_tween().tween_property(self, "scale", Vector2(target_scale, target_scale), 0.25).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)

func get_xp_for_level(lvl: int) -> int:
	return xp_progression.get_xp_for_level(lvl)

func get_rank_title() -> String:
	return level_config.get_rank_title(level)

func get_rank_color() -> Color:
	return level_config.get_rank_color(level)

func heal(amount: int) -> void:
	health = min(health + amount, max_health)
	health_changed.emit(health)


func equip_weapon(weapon: Weapon) -> void:
	equipped_weapon = weapon
	GameManager.equipped_weapon = weapon
	_apply_weapon()
	weapon_changed.emit(weapon)


func _apply_weapon() -> void:
	if equipped_weapon == null:
		return
	attack_damage = base_attack_damage + equipped_weapon.damage_bonus
	attack_cooldown = base_attack_cooldown * equipped_weapon.cooldown_multiplier * attack_speed_multiplier
	attack_timer.wait_time = attack_cooldown
	if sword_visual:
		sword_visual.color = equipped_weapon.trail_color


func equip_armor(armor: Armor) -> void:
	equipped_armor = armor
	GameManager.equipped_armor = armor
	_apply_armor_visual()
	_recalculate_speed()
	_apply_dash_cooldown()
	armor_changed.emit(armor)


func _recalculate_speed() -> void:
	var mult := 1.0
	if equipped_armor:
		mult = equipped_armor.move_speed_multiplier
	move_speed = (base_move_speed + level_move_bonus + gear_speed_bonus) * mult
	sprint_speed = (base_sprint_speed + level_sprint_bonus + gear_speed_bonus) * mult


func _apply_dash_cooldown() -> void:
	var mult := 1.0
	if equipped_armor:
		mult = equipped_armor.dash_cooldown_multiplier
	dash_cooldown = maxf(base_dash_cooldown * mult - gear_dash_reduction, 0.4)
	dash_cooldown_timer.wait_time = dash_cooldown


func _apply_armor_visual() -> void:
	if armor_visual == null:
		return
	if equipped_armor == null:
		armor_visual.visible = false
		return
	armor_visual.visible = true
	armor_visual.color = equipped_armor.armor_color
	armor_visual.modulate.a = 0.55


func apply_gear_up(gear_up: GearUp) -> void:
	match gear_up.stat:
		GearUp.Stat.ATTACK:
			base_attack_damage += gear_up.amount
			_apply_weapon()
		GearUp.Stat.MAX_HEALTH:
			max_health += gear_up.amount
			health = min(health + gear_up.amount, max_health)
			health_changed.emit(health)
		GearUp.Stat.SPEED:
			gear_speed_bonus += float(gear_up.amount)
			_recalculate_speed()
		GearUp.Stat.DASH_COOLDOWN:
			gear_dash_reduction += gear_up.amount * 0.05
			_apply_dash_cooldown()
		GearUp.Stat.CRIT_CHANCE:
			crit_chance = minf(crit_chance + float(gear_up.amount) * 0.05, 0.5)
		GearUp.Stat.LIFESTEAL:
			lifesteal = minf(lifesteal + float(gear_up.amount) * 0.05, 0.5)
		GearUp.Stat.XP_BONUS:
			xp_bonus += float(gear_up.amount) * 0.1
		GearUp.Stat.ARMOR:
			gear_armor_reduction += gear_up.amount
		GearUp.Stat.THORNS:
			thorns_damage += gear_up.amount
		GearUp.Stat.MAGNET:
			magnet_radius_bonus += float(gear_up.amount) * 0.5
		GearUp.Stat.REGEN:
			regen_per_second += float(gear_up.amount) * 0.25
		GearUp.Stat.FURY:
			attack_speed_multiplier = maxf(attack_speed_multiplier - float(gear_up.amount) * 0.05, 0.4)
			_apply_weapon()
		GearUp.Stat.KNOCKBACK:
			knockback_multiplier += float(gear_up.amount) * 0.25
		GearUp.Stat.CRIT_DAMAGE:
			crit_damage_multiplier = minf(crit_damage_multiplier + float(gear_up.amount) * 0.25, 4.0)
	gear_up_applied.emit(gear_up)


func get_xp_magnet_radius(base_radius: float) -> float:
	return base_radius * (1.0 + magnet_radius_bonus)


func _on_regen_timer_timeout() -> void:
	if is_dead or regen_per_second <= 0.0:
		return
	heal(maxi(roundi(regen_per_second), 1))


func _spawn_damage_number(amount: int) -> void:
	var number := DAMAGE_NUMBER.instantiate() as Label
	get_tree().current_scene.add_child(number)
	number.text = str(amount)
	number.modulate = Color(1.0, 0.35, 0.35)
	number.global_position = global_position + Vector2(randf_range(-6, 6), -16)

func _on_attack_timer_timeout() -> void:
	can_attack = true

func _on_invincibility_timer_timeout() -> void:
	is_invincible = false
	sprite.modulate = Color.WHITE

func _on_hit_flash_timer_timeout() -> void:
	if is_invincible:
		sprite.modulate = Color(1, 1, 1, 0.5) if sprite.modulate.a > 0.5 else Color(1, 1, 1, 1)
		hit_flash_timer.start()

func _on_hitbox_body_entered(body: Node2D) -> void:
	if body is Enemy and not body in hit_enemies_this_attack:
		hit_enemies_this_attack.append(body)
		var enemy := body as Enemy
		var damage := attack_damage
		var is_crit := false
		if crit_chance > 0.0 and randf() < crit_chance:
			damage = maxi(roundi(damage * crit_damage_multiplier), damage)
			is_crit = true
		enemy.knockback_multiplier = knockback_multiplier
		enemy.take_damage(damage, global_position, self)
		if is_crit:
			_spawn_crit_text(enemy)
		if lifesteal > 0.0:
			heal(maxi(roundi(damage * lifesteal), 1))
		if equipped_weapon and equipped_weapon.effect != Weapon.Effect.NONE and enemy.has_method("apply_status_from_weapon"):
			enemy.apply_status_from_weapon(equipped_weapon)
		if attack_sfx:
			AudioManager.play_sfx(attack_sfx)


func _spawn_crit_text(enemy: Node2D) -> void:
	var popup := CRIT_POPUP.instantiate() as Label
	get_tree().current_scene.add_child(popup)
	popup.text = "CRIT!"
	popup.modulate = Color(1.0, 0.9, 0.3)
	popup.global_position = enemy.global_position + Vector2(randf_range(-6, 6), -18)


func _on_combo_milestone(count: int) -> void:
	if is_dead:
		return
	var popup := CRIT_POPUP.instantiate() as Label
	get_tree().current_scene.add_child(popup)
	popup.text = "COMBO x%d!" % count
	popup.modulate = Color(1.0, 0.6, 0.2)
	popup.global_position = global_position + Vector2(0, -24)
