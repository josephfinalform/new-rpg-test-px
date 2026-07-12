class_name Player
extends CharacterBody2D

signal health_changed(new_health: int)
signal died

@export var move_speed: float = 100.0
@export var sprint_speed: float = 180.0
@export var max_health: int = 6
@export var attack_damage: int = 1
@export var attack_cooldown: float = 0.4
@export var invincibility_time: float = 1.0

var direction: Vector2 = Vector2.ZERO
var facing: Vector2 = Vector2.DOWN
var is_sprinting: bool = false
var health: int = 6
var is_invincible: bool = false
var can_attack: bool = true

@onready var sprite: Sprite2D = $Sprite2D
@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var state_machine: PlayerStateMachine = $StateMachine
@onready var attack_timer: Timer = $AttackTimer
@onready var invincibility_timer: Timer = $InvincibilityTimer
@onready var hit_flash_timer: Timer = $HitFlashTimer
@onready var hitbox_area: Area2D = $AttackPivot/HitboxArea
@onready var attack_pivot: Node2D = $AttackPivot

func _ready() -> void:
	state_machine.Initialize(self)
	health = max_health
	health_changed.emit(health)
	attack_timer.wait_time = attack_cooldown
	invincibility_timer.wait_time = invincibility_time
	hitbox_area.monitoring = false
	attack_pivot.rotation = 0

func get_input() -> void:
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

func update_facing_sprite() -> void:
	if abs(facing.x) > abs(facing.y):
		sprite.flip_h = facing.x < 0

func take_damage(amount: int) -> void:
	if is_invincible or health <= 0:
		return
	health = max(health - amount, 0)
	health_changed.emit(health)
	is_invincible = true
	invincibility_timer.start()
	hit_flash_timer.start()
	if health <= 0:
		died.emit()

func heal(amount: int) -> void:
	health = min(health + amount, max_health)
	health_changed.emit(health)

func _on_attack_timer_timeout() -> void:
	can_attack = true

func _on_invincibility_timer_timeout() -> void:
	is_invincible = false
	sprite.modulate = Color.WHITE

func _on_hit_flash_timer_timeout() -> void:
	if is_invincible:
		sprite.modulate = Color(1, 1, 1, 0.5) if sprite.modulate.a > 0.5 else Color(1, 1, 1, 1)
		hit_flash_timer.start()
