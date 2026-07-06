class_name Player
extends CharacterBody2D

@export var move_speed: float = 100.0

var direction: Vector2 = Vector2.ZERO
var facing: Vector2 = Vector2.DOWN

@onready var sprite: Sprite2D = $Sprite2D
@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var state_machine: PlayerStateMachine = $StateMachine

func _ready() -> void:
	state_machine.Initialize(self)

func _physics_process(_delta: float) -> void:
	get_input()
	update_movement()
	update_animation()
	move_and_slide()

# 🎮 INPUT
func get_input() -> void:
	direction = Vector2(
		Input.get_action_strength("right") - Input.get_action_strength("left"),
		Input.get_action_strength("down") - Input.get_action_strength("up")
	)

	if direction != Vector2.ZERO:
		direction = direction.normalized()
		facing = direction

# 🚶 MOVEMENT
func update_movement() -> void:
	velocity = direction * move_speed

# 🎬 ANIMATION + DIRECTION
func update_animation() -> void:
	if direction == Vector2.ZERO:
		# IDLE
		if abs(facing.x) > abs(facing.y):
			animation_player.play("idle_side")
			sprite.flip_h = facing.x < 0
		elif facing.y > 0:
			animation_player.play("idle_down")
		else:
			animation_player.play("idle_up")
	else:
		# WALK
		if abs(direction.x) > abs(direction.y):
			animation_player.play("walk_side")
			sprite.flip_h = direction.x < 0
		elif direction.y > 0:
			animation_player.play("walk_down")
		else:
			animation_player.play("walk_up")
