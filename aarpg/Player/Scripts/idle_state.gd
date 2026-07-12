class_name IdleState
extends State

@onready var walk_state: WalkState = $"../Walk"
@onready var attack_state: AttackState = $"../Attack"

func enter() -> void:
	player.velocity = Vector2.ZERO
	player.get_input()
	_play_idle_animation()
	player.attack_pivot.visible = false
	player.hitbox_area.monitoring = false

func process(_delta: float) -> State:
	player.get_input()
	if player.direction != Vector2.ZERO:
		return walk_state
	if Input.is_action_just_pressed("attack") and player.can_attack:
		return attack_state
	return null

func physics(_delta: float) -> State:
	player.move_and_slide()
	return null

func _play_idle_animation() -> void:
	if abs(player.facing.x) > abs(player.facing.y):
		player.play_animation("idle_side")
		player.sprite.flip_h = player.facing.x < 0
	elif player.facing.y > 0:
		player.play_animation("idle_down")
	else:
		player.play_animation("idle_up")
