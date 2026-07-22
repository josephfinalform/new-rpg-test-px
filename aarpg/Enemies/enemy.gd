class_name Enemy
extends CharacterBody2D

signal died

@export var max_health: int = 3
@export var move_speed: float = 40.0
@export var damage: int = 1
@export var knockback_resistance: float = 0.5
@export var knockback_force: float = 150.0

var health: int = 3
var is_invincible: bool = false
var knockback_velocity: Vector2 = Vector2.ZERO
var base_velocity: Vector2 = Vector2.ZERO

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

func _physics_process(delta: float) -> void:
	velocity = base_velocity + knockback_velocity
	knockback_velocity = knockback_velocity.lerp(Vector2.ZERO, 1.0 - exp(-5.0 * delta))
	move_and_slide()

func take_damage(amount: int, from_position: Vector2) -> void:
	if is_invincible:
		return
	health = max(health - amount, 0)
	is_invincible = true
	invincibility_timer.start()
	hurt_timer.start()
	sprite.modulate = Color.RED
	var knockback_dir = (global_position - from_position).normalized()
	knockback_velocity = knockback_dir * knockback_force * (1.0 - knockback_resistance)
	if health <= 0:
		died.emit()
		queue_free()

func _on_hitbox_body_entered(body: Node2D) -> void:
	if body is Player:
		body.take_damage(damage, global_position)

func _on_hurt_timer_timeout() -> void:
	sprite.modulate = Color.WHITE

func _on_invincibility_timer_timeout() -> void:
	is_invincible = false

func play_animation(anim_name: String) -> void:
	if animation_player.current_animation != anim_name:
		animation_player.play(anim_name)
