class_name PlayerStateMachine
extends Node

var current_state: State = null

func Initialize(player: Player) -> void:
	for c in get_children():
		if c is State:
			c.player = player

	if get_child_count() > 0:
		current_state = get_child(0)
		current_state.Enter()

func _process(delta: float) -> void:
	if current_state:
		var new_state = current_state.Process(delta)
		if new_state:
			change_state(new_state)

func _physics_process(delta: float) -> void:
	if current_state:
		var new_state = current_state.Physics(delta)
		if new_state:
			change_state(new_state)

func change_state(new_state: State) -> void:
	if new_state == null or new_state == current_state:
		return

	current_state.Exit()
	current_state = new_state
	current_state.Enter()
