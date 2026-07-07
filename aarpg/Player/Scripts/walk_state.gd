class_name WalkState
extends State

@onready var idle_state: IdleState = $"../Idle"

func Enter() -> void:
	pass

func Process(_delta: float) -> State:
	if player.direction == Vector2.ZERO:
		return idle_state

	return null


