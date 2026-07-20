class_name HurtState
extends State

@onready var idle_state: IdleState = $"../Idle"

var knockback_velocity: Vector2 = Vector2.ZERO
var knockback_duration: float = 0.2
var knockback_timer: float = 0.0

func enter() -> void:
	player.velocity = Vector2.ZERO
	knockback_timer = knockback_duration
	player.play_facing_animation("idle")

func exit() -> void:
	player.hit_flash_timer.stop()
	player.sprite.modulate = Color.WHITE

func process(delta: float) -> State:
	knockback_timer -= delta
	player.velocity = knockback_velocity * (knockback_timer / knockback_duration)
	if knockback_timer <= 0:
		player.get_input()
		return idle_state
	return null

func physics(_delta: float) -> State:
	player.move_and_slide()
	return null

func setup_knockback(direction: Vector2) -> void:
	knockback_velocity = direction.normalized() * 200.0
