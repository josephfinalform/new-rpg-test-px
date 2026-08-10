class_name Player
extends CharacterBody2D

const LEVEL_UP_EFFECT = preload("res://aarpg/Effects/level_up_effect.tscn")
const DAMAGE_NUMBER = preload("res://aarpg/Effects/damage_number.tscn")

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
var equipped_weapon: Weapon = null
var equipped_armor: Armor = null

@onready var armor_visual: Polygon2D = get_node_or_null("ArmorVisual")

var level: int = 1
var xp: int = 0
var xp_to_next_level: int = 10

var prestige: int = 0
var prestige_xp: int = 0

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

func _ready() -> void:
	state_machine.initialize(self)
	health = max_health
	health_changed.emit(health)
	xp_to_next_level = get_xp_for_level(level)
	attack_timer.wait_time = attack_cooldown
	invincibility_timer.wait_time = invincibility_time
	dash_timer.wait_time = dash_duration
	dash_cooldown_timer.wait_time = dash_cooldown
	hitbox_area.body_entered.connect(_on_hitbox_body_entered)
	attack_pivot.rotation = 0
	base_attack_damage = attack_damage
	base_attack_cooldown = attack_cooldown
	var default_weapon := load("res://aarpg/config/weapons/iron_sword.tres") as Weapon
	equipped_weapon = GameManager.equipped_weapon if GameManager.equipped_weapon != null else default_weapon
	_apply_weapon()
	if equipped_armor == null:
		equipped_armor = GameManager.equipped_armor
	_apply_armor_visual()

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

func take_damage(amount: int, from_position: Vector2 = global_position) -> void:
	if is_invincible or is_dead:
		return
	var final_amount := amount
	if equipped_armor:
		final_amount = maxi(final_amount - equipped_armor.damage_reduction, 1)
		final_amount = maxi(roundi(final_amount * (1.0 - equipped_armor.damage_reduction_ratio)), 1)
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
	if level >= level_config.max_level:
		_gain_prestige(amount)
		return
	xp += amount
	xp_changed.emit(xp, level)
	while xp >= xp_to_next_level:
		if level >= level_config.max_level:
			_gain_prestige(xp)
			xp = 0
			break
		xp -= xp_to_next_level
		_level_up()
	xp_changed.emit(xp, level)


func _gain_prestige(amount: int) -> void:
	prestige_xp += amount
	while prestige_xp >= level_config.prestige_xp_threshold:
		prestige_xp -= level_config.prestige_xp_threshold
		prestige += 1
		max_health += level_config.prestige_health_bonus
		health = min(health + level_config.prestige_health_bonus, max_health)
		base_attack_damage += level_config.prestige_attack_bonus
		_apply_weapon()
		move_speed += level_config.prestige_speed_bonus
		sprint_speed += level_config.prestige_speed_bonus
		health_changed.emit(health)
		prestige_changed.emit(prestige)
		_spawn_prestige_effect()
	xp_changed.emit(prestige_xp, level)


func _spawn_prestige_effect() -> void:
	var effect := LEVEL_UP_EFFECT.instantiate()
	get_tree().current_scene.add_child(effect)
	effect.global_position = global_position
	var stars := level_config.get_prestige_title(prestige)
	var stats_text := "HP +%d  ATK +%d  SPD +%d" % [
		level_config.prestige_health_bonus,
		level_config.prestige_attack_bonus,
		int(level_config.prestige_speed_bonus),
	]
	effect.setup(stats_text, "PRESTIGE " + stars, Color(1.0, 0.9, 0.4))

func _level_up() -> void:
	level += 1
	xp_to_next_level = get_xp_for_level(level)
	max_health += level_config.health_gain_per_level
	health = min(health + level_config.heal_on_level_up, max_health)
	base_attack_damage += level_config.damage_gain_per_level
	_apply_weapon()
	move_speed += level_config.move_speed_gain
	sprint_speed += level_config.sprint_speed_gain
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
	move_speed += spd_bonus
	sprint_speed += spd_bonus

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
	if lvl > level_config.max_level:
		return 0
	if lvl - 1 < level_config.xp_curve.size():
		return level_config.xp_curve[lvl - 1]
	return 5 + lvl * 3

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
	attack_cooldown = base_attack_cooldown * equipped_weapon.cooldown_multiplier
	attack_timer.wait_time = attack_cooldown
	if sword_visual:
		sword_visual.color = equipped_weapon.trail_color


func equip_armor(armor: Armor) -> void:
	equipped_armor = armor
	GameManager.equipped_armor = armor
	_apply_armor_visual()
	armor_changed.emit(armor)


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
			move_speed += float(gear_up.amount)
			sprint_speed += float(gear_up.amount)
		GearUp.Stat.DASH_COOLDOWN:
			dash_cooldown = maxf(dash_cooldown - gear_up.amount * 0.05, 0.4)
			dash_cooldown_timer.wait_time = dash_cooldown
	gear_up_applied.emit(gear_up)


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
		body.take_damage(attack_damage, global_position)
		if equipped_weapon and equipped_weapon.effect != Weapon.Effect.NONE and body.has_method("apply_status_from_weapon"):
			body.apply_status_from_weapon(equipped_weapon)
		if attack_sfx:
			AudioManager.play_sfx(attack_sfx)
