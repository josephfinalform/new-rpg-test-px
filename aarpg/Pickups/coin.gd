class_name Coin extends Area2D

@export var value: int = 1

@onready var sprite: Sprite2D = $Sprite2D
@onready var collision: CollisionShape2D = $CollisionShape2D
@onready var pickup_sound: AudioStreamPlayer2D = $PickupSound

func _ready() -> void:
	body_entered.connect(_on_body_entered)

func _on_body_entered(body: Node2D) -> void:
	if body is Player:
		body.collect_coin(value)
		collision.set_deferred("disabled", true)
		sprite.hide()
		pickup_sound.play()
		await pickup_sound.finished
		queue_free()
