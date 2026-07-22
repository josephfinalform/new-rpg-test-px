class_name IdleState
extends State

func enter() -> void:
	player.velocity = Vector2.ZERO
	player.get_input()
	player.play_facing_animation("idle")
	player.attack_pivot.visible = false
	player.hitbox_area.monitoring = false

func process(_delta: float) -> State:
	player.get_input()
	if player.direction != Vector2.ZERO:
		return get_state("walk")
	return check_attack_transition()
