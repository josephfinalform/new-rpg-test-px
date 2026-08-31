extends Node

signal gold_changed(amount: int)

var gold: int = 0


func grant(amount: int) -> void:
	if amount <= 0:
		return
	gold += amount
	gold_changed.emit(gold)


func spend(amount: int) -> bool:
	if amount < 0 or gold < amount:
		return false
	gold -= amount
	gold_changed.emit(gold)
	return true


func reset() -> void:
	gold = 0
	gold_changed.emit(0)
