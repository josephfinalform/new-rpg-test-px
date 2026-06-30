class_name IdleState extends State

@onready var walk_state: WalkState = $"../Walk" as WalkState

func Enter() -> void:
	player.UpdateAnimation("idle")

func Process(_delta: float) -> State:
	if player.direction != Vector2.ZERO:
		return walk_state
	player.SetDirection()
	return null

func Physics(_delta: float) -> State:
	player.velocity = Vector2.ZERO
	return null
