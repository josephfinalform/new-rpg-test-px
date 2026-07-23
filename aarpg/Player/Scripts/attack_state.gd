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
	player.animation_player.animation_finished.connect(_on_animation_finished, CONNECT_ONE_SHOT)

func exit() -> void:
	player.hitbox_area.monitoring = false
	player.attack_pivot.visible = false

func process(_delta: float) -> State:
	return null

func _on_animation_finished(_anim_name: String) -> void:
	player.get_input()
	if player.direction != Vector2.ZERO:
		player.state_machine.change_state(get_state("walk"))
	else:
		player.state_machine.change_state(get_state("idle"))
