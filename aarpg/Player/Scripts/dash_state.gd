class_name DashState
extends State

func enter() -> void:
	player.is_dashing = true
	player.can_attack = false
	var dir := player.facing
	if dir == Vector2.ZERO:
		dir = Vector2.DOWN
	player.dash_velocity = dir * player.dash_speed
	player.attack_pivot.visible = false
	player.hitbox_area.monitoring = false
	player.play_animation("walk")
	player.dash_timer.start()

func exit() -> void:
	player.is_dashing = false

func physics(_delta: float) -> State:
	if player.is_dead:
		return null
	player.velocity = player.dash_velocity
	if player.dash_timer.is_stopped():
		player.get_input()
		if player.direction != Vector2.ZERO:
			return get_state("walk")
		return get_state("idle")
	return null
