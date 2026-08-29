extends Node

var sfx_players: Array[AudioStreamPlayer] = []
var music_player: AudioStreamPlayer = null
const SFX_POOL_SIZE: int = 8

func _ready() -> void:
	for i in SFX_POOL_SIZE:
		var player = AudioStreamPlayer.new()
		player.bus = "Master"
		add_child(player)
		sfx_players.append(player)
	music_player = AudioStreamPlayer.new()
	music_player.bus = "Master"
	add_child(music_player)

func play_sfx(stream: AudioStream, volume_db: float = 0.0) -> void:
	if stream == null:
		return
	for player in sfx_players:
		if not player.playing:
			_play_on(player, stream, volume_db)
			return
	_play_on(sfx_players[0], stream, volume_db)


func _play_on(player: AudioStreamPlayer, stream: AudioStream, volume_db: float) -> void:
	player.stream = stream
	player.volume_db = volume_db
	player.play()

var _music_tween: Tween = null

func play_music(stream: AudioStream, fade_time: float = 1.0) -> void:
	if stream == null:
		return
	if _music_tween and _music_tween.is_valid():
		_music_tween.kill()
		_music_tween = null
	if music_player.playing:
		await _fade_music_down(fade_time * 0.5)
	music_player.stream = stream
	music_player.volume_db = 0.0
	music_player.play()
	if fade_time > 0.0:
		music_player.volume_db = -40.0
		_music_tween = create_tween()
		_music_tween.tween_property(music_player, "volume_db", 0.0, fade_time * 0.5)

func stop_music(fade_time: float = 0.5) -> void:
	if not music_player.playing:
		return
	await _fade_music_down(fade_time)
	music_player.stop()


func _fade_music_down(fade_time: float) -> void:
	_music_tween = create_tween()
	_music_tween.tween_property(music_player, "volume_db", -40.0, fade_time)
	await _music_tween.finished
