class_name Slime
extends Enemy

enum State { IDLE, CHASE, HURT, ATTACK }

var current_state: int = State.IDLE
var chase_target: Player = null
var idle_timer: float = 0.0
var idle_duration: float = 2.0
var idle_direction: Vector2 = Vector2.ZERO
var attack_cooldown: float = 0.0
var attack_range: float = 20.0

func _ready() -> void:
	super._ready()
	move_speed = 35.0
	max_health = 3
	health = max_health
	detection_area.body_entered.connect(_on_detection_body_entered)
	detection_area.body_exited.connect(_on_detection_body_exited)

func _physics_process(delta: float) -> void:
	match current_state:
		State.IDLE:
			_process_idle(delta)
		State.CHASE:
			_process_chase(delta)
		State.HURT:
			_process_hurt(delta)
		State.ATTACK:
			_process_attack(delta)
	super._physics_process(delta)

func _process_idle(delta: float) -> void:
	idle_timer += delta
	if idle_timer >= idle_duration:
		idle_timer = 0.0
		idle_duration = randf_range(1.0, 3.0)
		idle_direction = Vector2(randf_range(-1, 1), randf_range(-1, 1)).normalized()
		if idle_direction.length() < 0.1:
			idle_direction = Vector2.ZERO
	velocity = idle_direction * move_speed * 0.3
	move_and_slide()
	_update_idle_animation()
	if chase_target and is_instance_valid(chase_target):
		current_state = State.CHASE

func _process_chase(_delta: float) -> void:
	if not chase_target or not is_instance_valid(chase_target):
		current_state = State.IDLE
		return
	var dir = (chase_target.global_position - global_position).normalized()
	velocity = dir * move_speed
	move_and_slide()
	_update_chase_animation(dir)
	if global_position.distance_to(chase_target.global_position) < attack_range:
		current_state = State.ATTACK
		attack_cooldown = 0.5

func _process_hurt(_delta: float) -> void:
	move_and_slide()
	if hurt_timer.is_stopped():
		if chase_target and is_instance_valid(chase_target):
			current_state = State.CHASE
		else:
			current_state = State.IDLE

func _process_attack(delta: float) -> void:
	velocity = Vector2.ZERO
	move_and_slide()
	attack_cooldown -= delta
	if attack_cooldown <= 0:
		if chase_target and is_instance_valid(chase_target):
			if global_position.distance_to(chase_target.global_position) < attack_range * 2:
				current_state = State.CHASE
			else:
				current_state = State.IDLE
		else:
			current_state = State.IDLE

func take_damage(amount: int, from_position: Vector2) -> void:
	super.take_damage(amount, from_position)
	current_state = State.HURT

func _on_detection_body_entered(body: Node2D) -> void:
	if body is Player:
		chase_target = body
		current_state = State.CHASE

func _on_detection_body_exited(body: Node2D) -> void:
	if body is Player:
		chase_target = null
		current_state = State.IDLE

func _update_idle_animation() -> void:
	if idle_direction == Vector2.ZERO:
		player_play("idle")
	else:
		player_play("move")
		sprite.flip_h = idle_direction.x < 0

func _update_chase_animation(dir: Vector2) -> void:
	player_play("move")
	sprite.flip_h = dir.x < 0

func player_play(anim_name: String) -> void:
	if animation_player.current_animation != anim_name:
		animation_player.play(anim_name)
