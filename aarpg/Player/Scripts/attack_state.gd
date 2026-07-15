class_name AttackState
extends State

@onready var idle_state: IdleState = $"../Idle"
@onready var walk_state: WalkState = $"../Walk"

func enter() -> void:
	player.can_attack = false
	player.velocity = Vector2.ZERO
	player.hit_enemies_this_attack.clear()
	player.attack_timer.start()
	player.update_attack_pivot()
	player.attack_pivot.visible = true
	player.hitbox_area.monitoring = true
	_play_attack_animation()

func exit() -> void:
	player.hitbox_area.monitoring = false
	player.attack_pivot.visible = false

func process(_delta: float) -> State:
	if not player.animation_player.is_playing():
		player.get_input()
		if player.direction != Vector2.ZERO:
			return walk_state
		return idle_state
	return null

func physics(_delta: float) -> State:
	player.move_and_slide()
	return null

func _play_attack_animation() -> void:
	if abs(player.facing.x) > abs(player.facing.y):
		player.play_animation("attack_side")
		player.sprite.flip_h = player.facing.x < 0
	elif player.facing.y > 0:
		player.play_animation("attack_down")
	else:
		player.play_animation("attack_up")
