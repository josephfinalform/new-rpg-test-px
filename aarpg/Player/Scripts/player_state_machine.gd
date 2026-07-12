class_name PlayerStateMachine
extends Node

@onready var current_state: State = null
var states: Dictionary = {}

func Initialize(player: Player) -> void:
	for child in get_children():
		if child is State:
			child.player = player
			states[child.name.to_lower()] = child

	current_state = get_child(0) as State
	current_state.enter()

func _process(delta: float) -> void:
	if current_state:
		var new_state = current_state.process(delta)
		if new_state:
			change_state(new_state)

func _physics_process(delta: float) -> void:
	if current_state:
		var new_state = current_state.physics(delta)
		if new_state:
			change_state(new_state)

func change_state(new_state: State) -> void:
	if new_state == null or new_state == current_state:
		return

	current_state.exit()
	current_state = new_state
	current_state.enter()
