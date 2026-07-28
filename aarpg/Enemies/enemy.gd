class_name Enemy
extends CharacterBody2D

signal died

enum State { IDLE, CHASE, HURT, ATTACK }

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

var health: int = 3
var is_invincible: bool = false
var is_dead: bool = false
var knockback_velocity: Vector2 = Vector2.ZERO
var base_velocity: Vector2 = Vector2.ZERO

var current_state: int = State.IDLE
var chase_target: Player = null
var idle_timer: float = 0.0
var idle_duration: float = 2.0
var idle_direction: Vector2 = Vector2.ZERO
var attack_cooldown: float = 0.0

@onready var sprite: Sprite2D = $Sprite2D
@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var hitbox_area: Area2D = $HitboxArea
@onready var detection_area: Area2D = $DetectionArea
@onready var hurt_timer: Timer = $HurtTimer
@onready var invincibility_timer: Timer = $InvincibilityTimer

func _ready() -> void:
	health = max_health
	hurt_timer.wait_time = 0.3
	invincibility_timer.wait_time = 0.5
	hitbox_area.body_entered.connect(_on_hitbox_body_entered)
	detection_area.body_entered.connect(_on_detection_body_entered)
	detection_area.body_exited.connect(_on_detection_body_exited)

func _physics_process(delta: float) -> void:
	if is_dead:
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
	move_and_slide()

func _process_idle(delta: float) -> void:
	idle_timer += delta
	if idle_timer >= idle_duration:
		idle_timer = 0.0
		idle_duration = randf_range(idle_duration_min, idle_duration_max)
		idle_direction = Vector2(randf_range(-1, 1), randf_range(-1, 1)).normalized()
		if idle_direction.length() < 0.1:
			idle_direction = Vector2.ZERO
	velocity = idle_direction * move_speed * idle_speed_ratio
	base_velocity = velocity
	_update_idle_animation()
	if chase_target and is_instance_valid(chase_target):
		current_state = State.CHASE

func _process_chase(_delta: float) -> void:
	if not chase_target or not is_instance_valid(chase_target):
		current_state = State.IDLE
		return
	var dir: Vector2 = (chase_target.global_position - global_position).normalized()
	velocity = dir * move_speed
	base_velocity = velocity
	_update_chase_animation(dir)
	if global_position.distance_to(chase_target.global_position) < attack_range:
		current_state = State.ATTACK
		attack_cooldown = attack_cooldown_time

func _process_hurt(_delta: float) -> void:
	if hurt_timer.is_stopped():
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

func take_damage(amount: int, from_position: Vector2) -> void:
	if is_invincible or is_dead:
		return
	health = max(health - amount, 0)
	is_invincible = true
	invincibility_timer.start()
	hurt_timer.start()
	sprite.modulate = Color.RED
	if hit_sfx:
		AudioManager.play_sfx(hit_sfx)
	if not is_dead:
		current_state = State.HURT
	var knockback_dir: Vector2 = (global_position - from_position).normalized()
	knockback_velocity = knockback_dir * knockback_force * (1.0 - knockback_resistance)
	if health <= 0:
		_die()

func _die() -> void:
	if is_dead:
		return
	is_dead = true
	died.emit()
	current_state = State.IDLE
	hitbox_area.set_deferred("monitoring", false)
	var players = get_tree().get_nodes_in_group("player")
	if players.size() > 0:
		var player = players[0] as Player
		if player and not player.is_dead:
			player.gain_xp(xp_reward)
	if death_sfx:
		AudioManager.play_sfx(death_sfx)
	_play_death_effect()

func _play_death_effect() -> void:
	var tween: Tween = create_tween()
	tween.set_parallel(true)
	tween.tween_property(sprite, "modulate:a", 0.0, 0.3)
	tween.tween_property(sprite, "scale", Vector2(1.5, 1.5), 0.15).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_IN)
	tween.chain().tween_property(sprite, "scale", Vector2(0.0, 0.0), 0.15).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_IN)
	tween.tween_callback(queue_free)

func _on_hitbox_body_entered(body: Node2D) -> void:
	if body is Player:
		body.take_damage(damage, global_position)

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
