class_name State
extends Node

var player: Player

func get_state(state_name: String) -> State:
	return get_parent().states[state_name.to_lower()]

func check_attack_transition() -> State:
	if Input.is_action_just_pressed("attack") and player.can_attack:
		return get_state("attack")
	return null

func enter() -> void:
	pass

func exit() -> void:
	pass

func process(_delta: float) -> State:
	return null

func physics(_delta: float) -> State:
	return null
