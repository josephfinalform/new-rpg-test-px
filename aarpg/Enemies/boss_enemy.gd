class_name BossEnemy
extends Enemy

signal phase_changed(new_phase: int)

@export_group("Boss Settings")
@export var phase_health_thresholds: Array[float] = [0.66, 0.33]
@export var phase_transition_time: float = 1.5
@export var enrage_speed_mult: float = 1.3
@export var enrage_damage_mult: float = 1.25
@export var enrage_cooldown_mult: float = 0.8
@export var bonus_xp_reward: int = 50

var current_phase: int = 0
var max_phases: int = 1
var is_transitioning: bool = false

@onready var boss_health_bar: ProgressBar = $BossHealthBar
@onready var hp_tween: Tween


func _ready() -> void:
	super()
	max_phases = phase_health_thresholds.size() + 1
	if boss_health_bar:
		boss_health_bar.max_value = max_health
		boss_health_bar.value = health


func take_damage(amount: int, from_position: Vector2, attacker: Node2D = null) -> void:
	super(amount, from_position, attacker)
	if boss_health_bar:
		if hp_tween and hp_tween.is_valid():
			hp_tween.kill()
		hp_tween = create_tween()
		hp_tween.tween_property(boss_health_bar, "value", health, 0.15)
	if not is_dead:
		_check_phase_transition()


func _check_phase_transition() -> void:
	if is_transitioning or is_dead:
		return
	var health_ratio: float = float(health) / float(max_health)
	while current_phase < phase_health_thresholds.size() and health_ratio <= phase_health_thresholds[current_phase]:
		current_phase += 1
		_start_phase_transition()
		return


func _start_phase_transition() -> void:
	is_transitioning = true
	is_invincible = true
	current_state = State.HURT
	phase_changed.emit(current_phase)
	_play_phase_effect()
	await get_tree().create_timer(phase_transition_time).timeout
	_apply_phase_scaling()
	is_transitioning = false
	is_invincible = false
	sprite.modulate = Color.WHITE
	if chase_target and is_instance_valid(chase_target):
		current_state = State.CHASE
	else:
		current_state = State.IDLE


func _play_phase_effect() -> void:
	sprite.modulate = Color(1, 0.3, 0.3)
	var tween = create_tween()
	tween.tween_property(sprite, "scale", Vector2(1.4, 1.4), 0.3).set_trans(Tween.TRANS_ELASTIC)
	tween.tween_property(sprite, "scale", Vector2(1.0, 1.0), 0.3).set_trans(Tween.TRANS_BACK)
	if boss_health_bar:
		boss_health_bar.modulate = Color.RED
		await get_tree().create_timer(0.3).timeout
		boss_health_bar.modulate = Color.WHITE


func _apply_phase_scaling() -> void:
	move_speed *= 1.0 + (enrage_speed_mult - 1.0) * float(current_phase) / float(max_phases)
	var dmg_mult: float = 1.0 + (enrage_damage_mult - 1.0) * float(current_phase) / float(max_phases)
	damage = ceili(float(damage) * dmg_mult)
	var cd_mult: float = 1.0 - (1.0 - enrage_cooldown_mult) * float(current_phase) / float(max_phases)
	attack_cooldown_time = max(0.15, attack_cooldown_time * cd_mult)


func _die() -> void:
	if boss_health_bar:
		boss_health_bar.hide()
	super()
	var players = get_tree().get_nodes_in_group("player")
	if players.size() > 0:
		var player = players[0] as Player
		if player and not player.is_dead:
			player.gain_xp(bonus_xp_reward)


func _play_death_effect() -> void:
	var tween = create_tween()
	tween.set_parallel(true)
	tween.tween_property(sprite, "modulate:a", 0.0, 0.5)
	tween.tween_property(sprite, "scale", Vector2(2.0, 2.0), 0.4).set_trans(Tween.TRANS_ELASTIC)
	tween.chain().tween_property(sprite, "scale", Vector2(0.0, 0.0), 0.2)
	tween.tween_callback(queue_free)


func _process_hurt(_delta: float) -> void:
	if hurt_timer.is_stopped() and not is_transitioning:
		if is_dead:
			return
		if chase_target and is_instance_valid(chase_target):
			current_state = State.CHASE
		else:
			current_state = State.IDLE


func apply_level_scaling(level_index: int) -> void:
	if is_dead or level_index <= 0:
		return
	var hp_mult := 1.0 + 0.12 * float(level_index)
	var dmg_mult := 1.0 + 0.1 * float(level_index)
	var xp_mult := 1.0 + 0.1 * float(level_index)
	max_health = ceili(float(max_health) * hp_mult)
	health = max_health
	damage = ceili(float(damage) * dmg_mult)
	xp_reward = roundi(float(xp_reward) * xp_mult)
	if boss_health_bar:
		boss_health_bar.max_value = max_health
		boss_health_bar.value = health
