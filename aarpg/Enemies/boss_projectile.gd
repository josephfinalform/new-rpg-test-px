class_name BossProjectile
extends Area2D

var direction: Vector2 = Vector2.RIGHT
var speed: float = 120.0
var damage: int = 1
var lifetime: float = 3.0

@onready var sprite: Sprite2D = $Sprite2D
@onready var collision: CollisionShape2D = $CollisionShape2D
@onready var death_timer: Timer = $DeathTimer


func _ready() -> void:
	body_entered.connect(_on_body_entered)
	death_timer.wait_time = lifetime
	death_timer.start()
	death_timer.timeout.connect(queue_free)
	if sprite:
		sprite.rotation = direction.angle()


func _physics_process(delta: float) -> void:
	position += direction * speed * delta


func _on_body_entered(body: Node2D) -> void:
	if body is Player:
		body.take_damage(damage, global_position)
		queue_free()
	elif body is Enemy:
		pass
	else:
		queue_free()
