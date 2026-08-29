class_name Player
extends CharacterBody2D

signal health_changed(new_health: int)
signal died
signal xp_changed(new_xp: int, new_level: int)
signal level_up(new_level: int)
signal prestige_changed(prestige: int)
signal weapon_changed(weapon: Weapon)
signal armor_changed(armor: Armor)
signal gear_up_applied(gear_up: GearUp)

const DEFAULT_WEAPON = preload("res://aarpg/config/weapons/iron_sword.tres")


static func find_in_tree(tree: SceneTree) -> Player:
	var players := tree.get_nodes_in_group("player")
	return players[0] as Player if not players.is_empty() else null


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
var is_dashing: bool = false
var dash_velocity: Vector2 = Vector2.ZERO

var base_attack_damage: int:
	get:
		return combat.base_attack_damage if combat else attack_damage
	set(value):
		if combat:
			combat.base_attack_damage = value
var base_move_speed: float = 100.0
var base_sprint_speed: float = 180.0
var equipped_weapon: Weapon = null
var equipped_armor: Armor = null
var combat: PlayerCombatHandler
var progression: PlayerProgressionHandler
var effects: PlayerEffectsHandler

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

var level_config: LevelConfig = GameManager.LEVEL_CONFIG

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
@onready var armor_visual: Polygon2D = get_node_or_null("ArmorVisual")


func _ready() -> void:
	combat = PlayerCombatHandler.new(self)
	progression = PlayerProgressionHandler.new(self)
	effects = PlayerEffectsHandler.new(self)

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
	base_move_speed = move_speed
	base_sprint_speed = sprint_speed
	combat.base_attack_cooldown = attack_cooldown
	equipped_weapon = GameManager.equipped_weapon if GameManager.equipped_weapon != null else DEFAULT_WEAPON
	combat.equip_weapon(equipped_weapon)
	_ready_equipment_setup()


func _ready_equipment_setup() -> void:
	if equipped_armor == null:
		equipped_armor = GameManager.equipped_armor
	_refresh_equipment_tuning()


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
	if combat.thorns_damage > 0 and attacker is Enemy:
		var enemy := attacker as Enemy
		if not enemy.is_dead:
			enemy.take_damage(combat.thorns_damage, global_position)
	var final_amount := combat.apply_damage_reduction(amount)
	health = max(health - final_amount, 0)
	health_changed.emit(health)
	effects.spawn_damage_number(final_amount)
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
	progression.gain_xp(amount)


func gain_xp_flat(amount: int) -> void:
	progression.gain_xp_flat(amount)


func gain_level() -> void:
	progression.gain_level()


func get_xp_multiplier() -> float:
	return progression.get_xp_multiplier()


func get_xp_magnet_radius(base_radius: float) -> float:
	return progression.get_xp_magnet_radius(base_radius)


func heal(amount: int) -> void:
	health = min(health + amount, max_health)
	health_changed.emit(health)


func equip_weapon(weapon: Weapon) -> void:
	combat.equip_weapon(weapon)


func equip_armor(armor: Armor) -> void:
	equipped_armor = armor
	GameManager.equipped_armor = armor
	_refresh_equipment_tuning()
	armor_changed.emit(armor)


func apply_gear_up(gear_up: GearUp) -> void:
	progression.apply_gear_up(gear_up)


func allocate_prestige_point(tree: LevelConfig.PrestigeTree) -> bool:
	if not xp_progression.allocate_prestige_point(tree):
		return false
	progression.apply_prestige_tree_bonuses()
	return true


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


func get_xp_for_level(lvl: int) -> int:
	return xp_progression.get_xp_for_level(lvl)


func get_rank_title() -> String:
	return level_config.get_rank_title(level)


func get_rank_color() -> Color:
	return level_config.get_rank_color(level)


func _refresh_equipment_tuning() -> void:
	_apply_armor_visual()
	_recalculate_speed()
	_apply_dash_cooldown()


func _recalculate_speed() -> void:
	var mult := 1.0
	if equipped_armor:
		mult = equipped_armor.move_speed_multiplier
	move_speed = (base_move_speed + progression.level_move_bonus + progression.gear_speed_bonus) * mult
	sprint_speed = (base_sprint_speed + progression.level_sprint_bonus + progression.gear_speed_bonus) * mult


func _apply_dash_cooldown() -> void:
	var mult := 1.0
	if equipped_armor:
		mult = equipped_armor.dash_cooldown_multiplier
	dash_cooldown = maxf(1.2 * mult - progression.gear_dash_reduction, 0.4)
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


func _animate_level_scale() -> void:
	var target_scale := minf(1.0 + 0.03 * float(level), 1.5)
	create_tween().tween_property(self, "scale", Vector2(target_scale, target_scale), 0.25).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)


func _spawn_level_up_effect() -> void:
	effects.spawn_level_up_effect()


func _spawn_prestige_effect() -> void:
	effects.spawn_prestige_effect()


func _spawn_damage_number(amount: int) -> void:
	effects.spawn_damage_number(amount)


func _spawn_crit_text(enemy: Node2D) -> void:
	effects.spawn_crit_text(enemy)


func _on_progression_xp_changed(current_xp: int, lvl: int) -> void:
	xp_changed.emit(current_xp, lvl)


func _on_progression_level_gained(_new_level: int) -> void:
	progression.apply_level_up()


func _on_progression_prestige_gained(_new_prestige: int) -> void:
	_spawn_prestige_effect()
	prestige_changed.emit(prestige)


func _on_regen_timer_timeout() -> void:
	if is_dead or progression.regen_per_second <= 0.0:
		return
	heal(maxi(roundi(progression.regen_per_second), 1))


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
	combat.process_hitbox_body_entered(body)


func _on_combo_milestone(count: int) -> void:
	if is_dead:
		return
	effects.spawn_combo_milestone(count)
