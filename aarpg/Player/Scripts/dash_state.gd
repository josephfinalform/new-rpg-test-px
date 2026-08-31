class_name DashState
extends State

func enter() -> void:
	player.is_dashing = true
	player.is_invincible = true
	player.hit_flash_timer.stop()
	player.sprite.modulate = Color(1, 1, 1, 0.5)
	var dir := player.facing
	if dir == Vector2.ZERO:
		dir = Vector2.DOWN
	player.dash_velocity = dir * player.dash_speed
	player.attack_pivot.visible = false
	player.hitbox_area.monitoring = false
	player.play_facing_animation("walk", player.facing)
	player.dash_timer.start()

func exit() -> void:
	player.is_dashing = false
	player.is_invincible = false
	player.sprite.modulate = Color.WHITE

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
