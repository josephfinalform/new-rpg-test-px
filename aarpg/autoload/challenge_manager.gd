extends Node

signal challenge_started(mode: String)
signal challenge_failed(mode: String)
signal challenge_completed(mode: String, score: int)
signal timer_tick(time_left: float)

enum Mode { TIME_ATTACK, ENDLESS_WAVE }

var current_mode: int = -1
var is_active: bool = false
var _time_limit: float = 0.0
var _timer: float = 0.0
var _wave_count: int = 0
var _kills: int = 0
var _wave_manager: Node = null

const TIME_ATTACK_LIMIT := 900.0
const TIME_ATTACK_BONUS_PER_KILL := 0.5
const ENDLESS_WAVE_BASE_INTERVAL := 15.0


func start_time_attack(wave_mgr: Node) -> void:
	current_mode = Mode.TIME_ATTACK
	is_active = true
	_time_limit = TIME_ATTACK_LIMIT
	_timer = 0.0
	_kills = 0
	_wave_manager = wave_mgr
	challenge_started.emit("TIME ATTACK")


func start_endless_wave(wave_mgr: Node) -> void:
	current_mode = Mode.ENDLESS_WAVE
	is_active = true
	_wave_count = 0
	_kills = 0
	_wave_manager = wave_mgr
	challenge_started.emit("ENDLESS WAVE")


func _process(delta: float) -> void:
	if not is_active:
		return
	match current_mode:
		Mode.TIME_ATTACK:
			_process_time_attack(delta)
		Mode.ENDLESS_WAVE:
			_process_endless(delta)


func _process_time_attack(delta: float) -> void:
	_timer += delta
	var remaining := _time_limit - _timer
	timer_tick.emit(remaining)
	if remaining <= 0.0:
		_end_challenge()


func _process_endless(delta: float) -> void:
	_timer += delta


func on_enemy_killed() -> void:
	if not is_active:
		return
	_kills += 1
	if current_mode == Mode.TIME_ATTACK:
		_time_limit += TIME_ATTACK_BONUS_PER_KILL


func on_wave_cleared() -> void:
	if not is_active:
		return
	if current_mode == Mode.ENDLESS_WAVE:
		_wave_count += 1


func _end_challenge() -> void:
	is_active = false
	var score := _calculate_score()
	if current_mode == Mode.TIME_ATTACK:
		challenge_completed.emit("TIME ATTACK", score)
	else:
		challenge_completed.emit("ENDLESS WAVE", score)
	current_mode = -1


func force_fail() -> void:
	if not is_active:
		return
	is_active = false
	challenge_failed.emit("FAILED")
	current_mode = -1


func _calculate_score() -> int:
	match current_mode:
		Mode.TIME_ATTACK:
			return _kills * 100 + int(_time_limit - _timer) * 10
		Mode.ENDLESS_WAVE:
			return _wave_count * 500 + _kills * 50
	return 0


func get_time_remaining() -> float:
	if current_mode == Mode.TIME_ATTACK:
		return maxf(_time_limit - _timer, 0.0)
	return 0.0


func get_kills() -> int:
	return _kills


func get_waves_cleared() -> int:
	return _wave_count
