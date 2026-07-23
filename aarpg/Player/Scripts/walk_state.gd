class_name WalkState
extends State

func enter() -> void:
	player.attack_pivot.visible = false
	player.hitbox_area.monitoring = false

func process(_delta: float) -> State:
	if player.is_dead:
		return null
	player.get_input()
	if player.direction == Vector2.ZERO:
		return get_state("idle")
	var attack = check_attack_transition()
	if attack:
		return attack
	_update_movement()
	player.play_facing_animation("walk", player.direction)
	return null

func _update_movement() -> void:
	player.is_sprinting = Input.is_action_pressed("sprint") and player.direction != Vector2.ZERO
	var speed = player.sprint_speed if player.is_sprinting else player.move_speed
	player.velocity = player.direction * speed
