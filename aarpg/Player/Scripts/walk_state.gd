class_name WalkState
extends State

@onready var idle_state: IdleState = $"../Idle"
@onready var attack_state: AttackState = $"../Attack"

func enter() -> void:
	player.attack_pivot.visible = false
	player.hitbox_area.monitoring = false

func process(_delta: float) -> State:
	player.get_input()
	if player.direction == Vector2.ZERO:
		return idle_state
	if Input.is_action_just_pressed("attack") and player.can_attack:
		return attack_state
	_update_movement()
	_update_walk_animation()
	return null

func physics(_delta: float) -> State:
	player.move_and_slide()
	return null

func _update_movement() -> void:
	player.is_sprinting = Input.is_action_pressed("sprint") and player.direction != Vector2.ZERO
	var speed = player.sprint_speed if player.is_sprinting else player.move_speed
	player.velocity = player.direction * speed

func _update_walk_animation() -> void:
	if abs(player.direction.x) > abs(player.direction.y):
		player.play_animation("walk_side")
		player.sprite.flip_h = player.direction.x < 0
	elif player.direction.y > 0:
		player.play_animation("walk_down")
	else:
		player.play_animation("walk_up")
