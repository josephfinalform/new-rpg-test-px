class_name Goblin extends CharacterBody2D

var health: int = 30
var move_speed: float = 40.0
var damage: int = 10
var player: Player

@onready var sprite: Sprite2D = $Sprite2D
@onready var collision: CollisionShape2D = $CollisionShape2D

func _ready() -> void:
	player = get_tree().get_first_node_in_group("player")

func _physics_process(_delta: float) -> void:
	if not player:
		return
	var dir: Vector2 = global_position.direction_to(player.global_position)
	velocity = dir * move_speed
	move_and_slide()

	for i in get_slide_collision_count():
		var col = get_slide_collision(i)
		if col.get_collider() == player:
			player.take_damage(damage)

func take_damage(amount: int) -> void:
	health -= amount
	if health <= 0:
		queue_free()
