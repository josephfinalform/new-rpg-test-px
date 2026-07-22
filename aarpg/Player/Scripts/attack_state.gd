class_name AttackState
extends State

func enter() -> void:
	player.can_attack = false
	player.velocity = Vector2.ZERO
	player.hit_enemies_this_attack.clear()
	player.attack_timer.start()
	player.update_attack_pivot()
	player.attack_pivot.visible = true
	player.hitbox_area.monitoring = true
	player.play_facing_animation("attack")

func exit() -> void:
	player.hitbox_area.monitoring = false
	player.attack_pivot.visible = false

func process(_delta: float) -> State:
	if not player.animation_player.is_playing():
		player.get_input()
		if player.direction != Vector2.ZERO:
			return get_state("walk")
		return get_state("idle")
	return null
