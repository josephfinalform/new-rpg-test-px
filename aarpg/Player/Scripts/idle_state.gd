class_name IdleState extends State

func Enter() -> void:
	player.UpdateAnimation("idle")

func Process(_delta: float) -> State:
	if player.direction != Vector2.ZERO:
		return get_node("../Walk")
	player.SetDirection()
	return null

func Physics(_delta: float) -> State:
	player.velocity = Vector2.ZERO
	return null
