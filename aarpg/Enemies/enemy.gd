class_name Enemy
extends CharacterBody2D

signal died

enum State { IDLE, CHASE, HURT, ATTACK }

const HEART_SCENE = preload("res://aarpg/Pickups/heart_pickup.tscn")
const XP_POPUP = preload("res://aarpg/Effects/floating_text.tscn")
const XP_GEM_SCENE = preload("res://aarpg/Pickups/xp_gem.tscn")
const POTION_SCENE = preload("res://aarpg/Pickups/potion_pickup.tscn")
const DAMAGE_NUMBER = preload("res://aarpg/Effects/damage_number.tscn")
const PROJECTILE_SCENE = preload("res://aarpg/Enemies/boss_projectile.tscn")
const BURN_TICK_INTERVAL := 0.5

@export var enemy_data: EnemyData
@export var max_health: int = 3
@export var move_speed: float = 40.0
@export var damage: int = 1
@export var knockback_resistance: float = 0.5
@export var knockback_force: float = 150.0
@export var death_sfx: AudioStream
@export var hit_sfx: AudioStream

@export_group("AI Tuning")
@export var idle_speed_ratio: float = 0.3
@export var idle_duration_min: float = 1.0
@export var idle_duration_max: float = 3.0
@export var attack_range: float = 20.0
@export var attack_cooldown_time: float = 0.5
@export var xp_reward: int = 8

@export_group("Drops & Feedback")
@export_range(0.0, 1.0) var heart_drop_chance: float = 0.15
@export_range(0.0, 1.0) var xp_gem_drop_chance: float = 0.0
@export_range(0.0, 1.0) var potion_drop_chance: float = 0.0
@export var xp_popup_enabled: bool = true

var health: int = 3
var is_invincible: bool = false
var is_dead: bool = false
var is_transitioning: bool = false
var knockback_velocity: Vector2 = Vector2.ZERO
var base_velocity: Vector2 = Vector2.ZERO
var knockback_multiplier: float = 1.0

var current_state: int = State.IDLE
var chase_target: Player = null
var _cached_player: Player = null
var idle_timer: float = 0.0
var idle_duration: float = 2.0
var idle_direction: Vector2 = Vector2.ZERO
var attack_cooldown: float = 0.0

var slow_factor: float = 1.0
var slow_remaining: float = 0.0
var burn_damage: int = 0
var burn_remaining: float = 0.0
var burn_tick_timer: float = 0.0
var stun_remaining: float = 0.0

@onready var sprite: Sprite2D = $Sprite2D
@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var hitbox_area: Area2D = $HitboxArea
@onready var detection_area: Area2D = $DetectionArea
@onready var hurt_timer: Timer = $HurtTimer
@onready var invincibility_timer: Timer = $InvincibilityTimer

func _cache_player() -> void:
	_cached_player = Player.find_in_tree(get_tree())


func _apply_data(data: EnemyData) -> void:
	max_health = data.max_health
	move_speed = data.move_speed
	damage = data.damage
	xp_reward = data.xp_reward
	knockback_resistance = data.knockback_resistance
	knockback_force = data.knockback_force
	idle_speed_ratio = data.idle_speed_ratio
	idle_duration_min = data.idle_duration_min
	idle_duration_max = data.idle_duration_max
	attack_range = data.attack_range
	attack_cooldown_time = data.attack_cooldown_time
	heart_drop_chance = data.heart_drop_chance
	xp_gem_drop_chance = data.xp_gem_drop_chance
	potion_drop_chance = data.potion_drop_chance
	xp_popup_enabled = data.xp_popup_enabled
	death_sfx = data.death_sfx
	hit_sfx = data.hit_sfx
	if data.tint != Color.WHITE:
		sprite.self_modulate = data.tint
	if data.sprite_scale != Vector2.ONE:
		sprite.scale = data.sprite_scale


func _ready() -> void:
	if enemy_data:
		_apply_data(enemy_data)
	health = max_health
	hurt_timer.wait_time = 0.3
	invincibility_timer.wait_time = 0.5
	hitbox_area.body_entered.connect(_on_hitbox_body_entered)
	detection_area.body_entered.connect(_on_detection_body_entered)
	detection_area.body_exited.connect(_on_detection_body_exited)
	_cache_player()

func _physics_process(delta: float) -> void:
	if is_dead:
		return
	if stun_remaining > 0.0:
		stun_remaining = maxf(stun_remaining - delta, 0.0)
		velocity = Vector2.ZERO
		base_velocity = Vector2.ZERO
		move_and_slide()
		_update_status_visual()
		return
	match current_state:
		State.IDLE:
			_process_idle(delta)
		State.CHASE:
			_process_chase(delta)
		State.HURT:
			_process_hurt(delta)
		State.ATTACK:
			_process_attack(delta)
	velocity = base_velocity + knockback_velocity
	knockback_velocity = knockback_velocity.lerp(Vector2.ZERO, 1.0 - exp(-5.0 * delta))
	_process_status_effects(delta)
	move_and_slide()

func _process_status_effects(delta: float) -> void:
	if slow_remaining > 0.0:
		slow_remaining = maxf(slow_remaining - delta, 0.0)
		if slow_remaining == 0.0:
			slow_factor = 1.0
	if burn_remaining > 0.0:
		burn_tick_timer -= delta
		if burn_tick_timer <= 0.0:
			burn_tick_timer = BURN_TICK_INTERVAL
			burn_remaining -= BURN_TICK_INTERVAL
			_apply_burn_tick()
	_update_status_visual()

func _process_idle(delta: float) -> void:
	idle_timer += delta
	if idle_timer >= idle_duration:
		idle_timer = 0.0
		idle_duration = randf_range(idle_duration_min, idle_duration_max)
		idle_direction = Vector2(randf_range(-1, 1), randf_range(-1, 1)).normalized()
		if idle_direction.length() < 0.1:
			idle_direction = Vector2.ZERO
	velocity = idle_direction * move_speed * idle_speed_ratio * slow_factor
	base_velocity = velocity
	_update_idle_animation()
	if chase_target and is_instance_valid(chase_target):
		current_state = State.CHASE

func _process_chase(_delta: float) -> void:
	if not chase_target or not is_instance_valid(chase_target):
		current_state = State.IDLE
		return
	var dir: Vector2 = (chase_target.global_position - global_position).normalized()
	velocity = dir * move_speed * slow_factor
	base_velocity = velocity
	_update_chase_animation(dir)
	if global_position.distance_to(chase_target.global_position) < attack_range:
		current_state = State.ATTACK
		attack_cooldown = attack_cooldown_time

func _process_hurt(_delta: float) -> void:
	if hurt_timer.is_stopped() and not is_transitioning:
		if is_dead:
			return
		if chase_target and is_instance_valid(chase_target):
			current_state = State.CHASE
		else:
			current_state = State.IDLE

func _process_attack(delta: float) -> void:
	velocity = Vector2.ZERO
	base_velocity = Vector2.ZERO
	attack_cooldown -= delta
	if attack_cooldown <= 0:
		if chase_target and is_instance_valid(chase_target):
			if global_position.distance_to(chase_target.global_position) < attack_range * 2:
				current_state = State.CHASE
			else:
				current_state = State.IDLE
		else:
			current_state = State.IDLE

func take_damage(amount: int, from_position: Vector2, attacker: Node2D = null) -> void:
	if is_invincible or is_dead:
		return
	health = max(health - amount, 0)
	_spawn_damage_number(amount)
	is_invincible = true
	invincibility_timer.start()
	hurt_timer.start()
	sprite.modulate = Color.RED
	if hit_sfx:
		AudioManager.play_sfx(hit_sfx)
	if not is_dead:
		current_state = State.HURT
	var knockback_dir: Vector2 = (global_position - from_position).normalized()
	knockback_velocity = knockback_dir * knockback_force * (1.0 - knockback_resistance) * knockback_multiplier
	if health <= 0:
		_die()

func _die() -> void:
	if is_dead:
		return
	is_dead = true
	died.emit()
	current_state = State.IDLE
	hitbox_area.set_deferred("monitoring", false)
	_grant_player_xp(xp_reward)
	GameManager.enemy_killed()
	if heart_drop_chance > 0.0 and randf() < heart_drop_chance:
		_spawn_heart_drop()
	if xp_gem_drop_chance > 0.0 and randf() < xp_gem_drop_chance:
		_spawn_xp_gem()
	if potion_drop_chance > 0.0 and randf() < potion_drop_chance:
		_spawn_potion_drop()
	if xp_popup_enabled:
		_spawn_xp_popup()
	if death_sfx:
		AudioManager.play_sfx(death_sfx)
	_play_death_effect()

func _grant_player_xp(amount: int) -> void:
	if _cached_player and not _cached_player.is_dead:
		_cached_player.gain_xp(amount)

func _spawn_heart_drop() -> void:
	_spawn_drop(HEART_SCENE)

func _spawn_xp_gem() -> void:
	_spawn_drop(XP_GEM_SCENE)
	var popup := XP_POPUP.instantiate() as Label
	get_parent().add_child(popup)
	popup.text = "GEM"
	popup.global_position = global_position + Vector2(0, -22)

func _spawn_potion_drop() -> void:
	_spawn_drop(POTION_SCENE)

func _spawn_drop(scene: PackedScene, offset_y: float = -4.0) -> Node2D:
	var drop := scene.instantiate()
	get_parent().add_child(drop)
	drop.global_position = global_position + Vector2(randf_range(-8, 8), offset_y)
	return drop


func _spawn_xp_popup() -> void:
	var popup := XP_POPUP.instantiate() as Label
	get_parent().add_child(popup)
	popup.text = "+" + str(xp_reward)
	popup.global_position = global_position + Vector2(0, -14)


func _spawn_damage_number(amount: int) -> void:
	var number := DAMAGE_NUMBER.instantiate() as Label
	get_parent().add_child(number)
	number.text = str(amount)
	number.global_position = global_position + Vector2(randf_range(-6, 6), -16)


func spawn_projectile(direction: Vector2, speed: float, tint: Color = Color.WHITE, proj_scale: Vector2 = Vector2.ONE, from_marker: Marker2D = null) -> void:
	var projectile := PROJECTILE_SCENE.instantiate()
	projectile.global_position = from_marker.global_position if from_marker else global_position
	projectile.direction = direction
	projectile.speed = speed
	projectile.damage = damage
	projectile.projectile_tint = tint
	projectile.scale = proj_scale
	get_parent().add_child(projectile)

func _play_death_effect() -> void:
	var tween: Tween = create_tween()
	tween.set_parallel(true)
	tween.tween_property(sprite, "modulate:a", 0.0, 0.3)
	tween.tween_property(sprite, "scale", Vector2(1.5, 1.5), 0.15).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_IN)
	tween.chain().tween_property(sprite, "scale", Vector2(0.0, 0.0), 0.15).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_IN)
	tween.tween_callback(queue_free)

func _on_hitbox_body_entered(body: Node2D) -> void:
	if body is Player:
		body.take_damage(damage, global_position, self)

func _on_hurt_timer_timeout() -> void:
	if not is_dead:
		sprite.modulate = Color.WHITE

func _on_invincibility_timer_timeout() -> void:
	is_invincible = false

func _on_detection_body_entered(body: Node2D) -> void:
	if body is Player:
		chase_target = body
		current_state = State.CHASE

func _on_detection_body_exited(body: Node2D) -> void:
	if body is Player:
		chase_target = null
		current_state = State.IDLE

func _update_idle_animation() -> void:
	if idle_direction == Vector2.ZERO:
		play_animation("idle")
	else:
		play_animation("move")
		sprite.flip_h = idle_direction.x < 0

func _update_chase_animation(dir: Vector2) -> void:
	play_animation("move")
	sprite.flip_h = dir.x < 0

func play_animation(anim_name: String) -> void:
	if animation_player.current_animation != anim_name:
		animation_player.play(anim_name)


func _level_scaling_multipliers() -> Vector3:
	return Vector3(0.35, 0.2, 0.25)


func apply_level_scaling(level_index: int) -> void:
	if is_dead or level_index <= 0:
		return
	var mult := _level_scaling_multipliers()
	max_health = ceili(float(max_health) * (1.0 + mult.x * float(level_index)))
	health = max_health
	damage = ceili(float(damage) * (1.0 + mult.y * float(level_index)))
	xp_reward = roundi(float(xp_reward) * (1.0 + mult.z * float(level_index)))


func apply_status_from_weapon(weapon: Weapon) -> void:
	if is_dead:
		return
	match weapon.effect:
		Weapon.Effect.FIRE:
			apply_burn(1, 3)
		Weapon.Effect.FROST:
			apply_slow(1.6, 0.5)
		Weapon.Effect.SHOCK:
			apply_stun(0.8)


func apply_slow(duration: float, factor: float) -> void:
	if is_dead:
		return
	slow_remaining = maxf(slow_remaining, duration)
	slow_factor = factor


func apply_burn(damage: int, ticks: int) -> void:
	if is_dead:
		return
	burn_damage = damage
	burn_remaining = float(ticks) * BURN_TICK_INTERVAL
	burn_tick_timer = 0.0


func apply_stun(duration: float) -> void:
	if is_dead:
		return
	stun_remaining = maxf(stun_remaining, duration)


func _apply_burn_tick() -> void:
	if is_dead:
		return
	health = maxi(health - burn_damage, 0)
	_spawn_damage_number(burn_damage)
	if health <= 0:
		_die()


func _update_status_visual() -> void:
	var target := Color.WHITE
	if stun_remaining > 0.0:
		target = Color(0.35, 0.85, 1.0)
	elif burn_remaining > 0.0:
		target = Color(1.0, 0.6, 0.3)
	elif slow_remaining > 0.0:
		target = Color(0.65, 0.8, 1.0)
	modulate = modulate.lerp(target, 0.1)
