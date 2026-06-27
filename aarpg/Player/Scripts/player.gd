extends CharacterBody2D

var move_speed: float = 100.0
var direction: Vector2 = Vector2.ZERO
var cardinal_direction: Vector2 = Vector2.DOWN
var state: String = "idle"

@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var sprite: Sprite2D = $Sprite2D


func _process(delta):
	direction.x = Input.get_action_strength("right") - Input.get_action_strength("left")
	direction.y = Input.get_action_strength("down") - Input.get_action_strength("up")
	direction = direction.normalized()

	velocity = direction * move_speed

	SetDirection()
	SetState()
	UpdateAnimation()


func _physics_process(delta):
	move_and_slide()


func SetDirection():
	if direction == Vector2.ZERO:
		return

	if abs(direction.x) > abs(direction.y):
		if direction.x > 0:
			cardinal_direction = Vector2.RIGHT
			sprite.flip_h = false
		else:
			cardinal_direction = Vector2.LEFT
			sprite.flip_h = true
	else:
		if direction.y > 0:
			cardinal_direction = Vector2.DOWN
		else:
			cardinal_direction = Vector2.UP


func SetState():
	if direction == Vector2.ZERO:
		state = "idle"
	else:
		state = "walk"


func UpdateAnimation():
	var anim = state + "_" + AnimDirection()

	if animation_player.current_animation != anim:
		animation_player.play(anim)


func AnimDirection() -> String:
	if cardinal_direction == Vector2.UP:
		return "up"
	elif cardinal_direction == Vector2.DOWN:
		return "down"
	else:
		return "side"
