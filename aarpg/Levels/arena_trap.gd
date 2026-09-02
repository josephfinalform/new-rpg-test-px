class_name ArenaTrap
extends Area2D

enum TrapType { SPIKE_PIT, POISON_CLOUD, FIRE_GEO, SLOW_FIELD, PORTAL_TRAP }

@export var trap_type: TrapType = TrapType.SPIKE_PIT
@export var damage: int = 2
@export var tick_interval: float = 1.0
@export var slow_factor: float = 0.5
@export var slow_duration: float = 2.0
@export var duration: float = 0.0
@export var active: bool = true

var _tick_timer: float = 0.0
var _elapsed: float = 0.0
var _bodies: Array[Node2D] = []


func _ready() -> void:
	body_entered.connect(_on_body_entered)
	body_exited.connect(_on_body_exited)
	match trap_type:
		TrapType.SPIKE_PIT:
			.modulate = Color(0.7, 0.7, 0.7)
		TrapType.POISON_CLOUD:
			.modulate = Color(0.3, 0.8, 0.2, 0.6)
		TrapType.FIRE_GEO:
			.modulate = Color(1.0, 0.4, 0.1, 0.7)
		TrapType.SLOW_FIELD:
			.modulate = Color(0.4, 0.6, 1.0, 0.5)
		TrapType.PORTAL_TRAP:
			.modulate = Color(0.5, 0.1, 0.8, 0.6)


func _process(delta: float) -> void:
	if not active:
		return
	if duration > 0.0:
		_elapsed += delta
		if _elapsed >= duration:
			queue_free()
			return
	_tick_timer += delta
	if _tick_timer >= tick_interval:
		_tick_timer = 0.0
		_apply_trap_effect()


func _apply_trap_effect() -> void:
	for body in _bodies:
		if not body is Player:
			continue
		var player := body as Player
		match trap_type:
			TrapType.SPIKE_PIT, TrapType.FIRE_GEO:
				player.take_damage(damage, global_position)
			TrapType.POISON_CLOUD:
				player.take_damage(damage, global_position)
			TrapType.SLOW_FIELD:
				if player.has_method("apply_slow"):
					player.apply_slow(slow_duration, slow_factor)
			TrapType.PORTAL_TRAP:
				player.take_damage(damage, global_position)


func _on_body_entered(body: Node2D) -> void:
	if body is Player and active:
		_bodies.append(body)
		if trap_type == TrapType.SPIKE_PIT or trap_type == TrapType.FIRE_GEO:
			body.take_damage(damage, global_position)


func _on_body_exited(body: Node2D) -> void:
	_bodies.erase(body)
