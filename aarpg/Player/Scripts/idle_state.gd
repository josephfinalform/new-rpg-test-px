class_name IdleState
extends State

@onready var walk_state: WalkState = $"../Walk"

func Enter() -> void:
	player.velocity = Vector2.ZERO

func Process(_delta: float) -> State:
	if player.direction != Vector2.ZERO:
		return walk_state

	return null

func Physics(_delta: float) -> State:
	player.velocity = Vector2.ZERO
	return null
