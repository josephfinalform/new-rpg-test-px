class_name WizardBoss
extends BossEnemy

enum SpecialAttack { FIREBALL, TELEPORT, BEAM, SUMMON }

const FIREBALL_SCENE = preload("res://aarpg/Enemies/boss_projectile.tscn")
const SLIME_SCENE = preload("res://aarpg/Enemies/slime.tscn")
const BOSS_NAME := "WIZARD BOSS"


func get_boss_name() -> String:
	return BOSS_NAME

@export_group("Wizard Attacks")
@export var fireball_cooldown: float = 2.5
@export var teleport_cooldown: float = 4.0
@export var beam_cooldown: float = 6.0
@export var summon_cooldown: float = 8.0
@export var fireball_speed: float = 120.0
@export var teleport_range: float = 120.0
@export var beam_damage: int = 2
@export var minion_count: int = 2
@export var teleport_effect_scene: PackedScene

var fireball_timer: float = 0.0
var teleport_timer: float = 0.0
var beam_timer: float = 0.0
var summon_timer: float = 0.0
var is_casting: bool = false
var beam_target: Vector2 = Vector2.ZERO
var beam_active: bool = false

@onready var hand_sprite: Sprite2D = $Hand
@onready var beam_area: Area2D = $BeamArea
@onready var beam_collision: CollisionShape2D = $BeamArea/BeamCollision
@onready var beam_sprite: Sprite2D = $BeamSprite
@onready var spawn_marker: Marker2D = $SpawnMarker


func _ready() -> void:
	super()
	max_health = 30
	health = max_health
	move_speed = 50.0
	damage = 2
	xp_reward = 30
	bonus_xp_reward = 80
	attack_range = 28.0
	phase_health_thresholds = [0.66, 0.33]
	if beam_area:
		beam_area.body_entered.connect(_on_beam_body_entered)
		beam_collision.disabled = true
		beam_sprite.hide()


func _physics_process(delta: float) -> void:
	if is_dead or is_transitioning:
		return
	if is_casting:
		velocity = Vector2.ZERO
		base_velocity = Vector2.ZERO
		move_and_slide()
		return
	fireball_timer += delta
	teleport_timer += delta
	beam_timer += delta
	summon_timer += delta
	if current_state == State.CHASE or current_state == State.ATTACK:
		_evaluate_special_attacks()
	super(delta)


func _evaluate_special_attacks() -> void:
	if not chase_target or not is_instance_valid(chase_target):
		return
	var dist = global_position.distance_to(chase_target.global_position)
	if current_phase >= 2 and summon_timer >= summon_cooldown and dist < 150:
		_summon_minions()
		return
	if current_phase >= 1 and beam_timer >= beam_cooldown and dist < 100:
		_cast_beam()
		return
	if fireball_timer >= fireball_cooldown and dist < 130:
		_cast_fireball()
		return
	if teleport_timer >= teleport_cooldown and dist < 80:
		_teleport()
		return


func _cast_fireball() -> void:
	if is_casting:
		return
	is_casting = true
	fireball_timer = 0.0
	current_state = State.ATTACK
	play_animation("cast")
	await get_tree().create_timer(0.3).timeout
	if is_dead:
		is_casting = false
		return
	if chase_target and is_instance_valid(chase_target):
		var dir = (chase_target.global_position - global_position).normalized()
		var fireball = FIREBALL_SCENE.instantiate()
		fireball.global_position = spawn_marker.global_position if spawn_marker else global_position
		fireball.direction = dir
		fireball.speed = fireball_speed
		fireball.damage = damage
		get_parent().add_child(fireball)
	play_animation("move")
	is_casting = false
	if chase_target and is_instance_valid(chase_target):
		current_state = State.CHASE
	else:
		current_state = State.IDLE


func _teleport() -> void:
	if is_casting:
		return
	is_casting = true
	teleport_timer = 0.0
	current_state = State.HURT
	modulate = Color(1, 1, 1, 0.3)
	var tween = create_tween()
	tween.tween_property(self, "modulate", Color(1, 1, 1, 0), 0.2)
	await tween.finished
	if is_dead:
		is_casting = false
		return
	if chase_target and is_instance_valid(chase_target):
		var offset = Vector2(randf_range(-teleport_range, teleport_range), randf_range(-teleport_range, teleport_range))
		var new_pos = chase_target.global_position + offset
		var map_size = Vector2(480, 270)
		new_pos.x = clamp(new_pos.x, 20, map_size.x - 20)
		new_pos.y = clamp(new_pos.y, 20, map_size.y - 20)
		global_position = new_pos
	modulate = Color(1, 1, 1, 0.3)
	var fade_in = create_tween()
	fade_in.tween_property(self, "modulate", Color.WHITE, 0.15)
	await fade_in.finished
	is_casting = false
	if chase_target and is_instance_valid(chase_target):
		current_state = State.CHASE
	else:
		current_state = State.IDLE


func _cast_beam() -> void:
	if is_casting or not chase_target or not is_instance_valid(chase_target):
		return
	is_casting = true
	beam_timer = 0.0
	current_state = State.ATTACK
	play_animation("cast")
	await get_tree().create_timer(0.4).timeout
	if is_dead:
		is_casting = false
		return
	if chase_target and is_instance_valid(chase_target):
		var dir = (chase_target.global_position - global_position).normalized()
		beam_sprite.global_rotation = dir.angle()
		beam_sprite.show()
		beam_collision.disabled = false
		beam_active = true
		await get_tree().create_timer(0.6).timeout
		beam_sprite.hide()
		beam_collision.disabled = true
		beam_active = false
	play_animation("move")
	is_casting = false
	if chase_target and is_instance_valid(chase_target):
		current_state = State.CHASE
	else:
		current_state = State.IDLE


func _summon_minions() -> void:
	if is_casting:
		return
	is_casting = true
	summon_timer = 0.0
	current_state = State.ATTACK
	play_animation("cast")
	await get_tree().create_timer(0.5).timeout
	if is_dead:
		is_casting = false
		return
	for i in range(minion_count):
		var slime = SLIME_SCENE.instantiate()
		var offset = Vector2(randf_range(-40, 40), randf_range(-40, 40))
		slime.global_position = global_position + offset
		get_parent().add_child(slime)
	play_animation("move")
	is_casting = false
	if chase_target and is_instance_valid(chase_target):
		current_state = State.CHASE
	else:
		current_state = State.IDLE


func _on_beam_body_entered(body: Node2D) -> void:
	if beam_active and body is Player:
		body.take_damage(beam_damage, global_position)


func _play_phase_effect() -> void:
	super()
	sprite.modulate = Color(1, 0.2, 0.2)
	var tween = create_tween()
	tween.tween_property(sprite, "scale", Vector2(1.6, 1.6), 0.25).set_trans(Tween.TRANS_ELASTIC)
	tween.tween_property(sprite, "scale", Vector2(1.0, 1.0), 0.3).set_trans(Tween.TRANS_BACK)
	if current_phase == 1:
		fireball_cooldown = max(1.0, fireball_cooldown * 0.8)
		teleport_cooldown = max(2.0, teleport_cooldown * 0.7)
	elif current_phase == 2:
		fireball_cooldown = max(0.6, fireball_cooldown * 0.7)
		teleport_cooldown = max(1.0, teleport_cooldown * 0.6)
		summon_cooldown = max(5.0, summon_cooldown * 0.8)


func _apply_phase_scaling() -> void:
	super()
	if current_phase >= 1:
		minion_count = 2
	if current_phase >= 2:
		minion_count = 3
		beam_damage = 3
