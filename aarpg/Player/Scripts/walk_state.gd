class_name WalkState extends State

func Enter() -> void:
	player.UpdateAnimation("walk")

func Process(_delta: float) -> State:
	if player.direction == Vector2.ZERO:
		return get_node("../Idle")
	player.SetDirection()
	return null

func Physics(_delta: float) -> State:
	player.velocity = player.direction * player.move_speed
	return null
