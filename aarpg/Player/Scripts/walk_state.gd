class_name WalkState
extends State

@onready var idle_state: IdleState = $"../Idle"

func Enter() -> void:
	pass

func Process(_delta: float) -> State:
	if player.direction == Vector2.ZERO:
		return idle_state

	return null

func Physics(_delta: float) -> State:
	player.velocity = player.direction * player.move_speed
	return null
