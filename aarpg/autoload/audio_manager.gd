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
			player.stream = stream
			player.volume_db = volume_db
			player.play()
			return
	sfx_players[0].stream = stream
	sfx_players[0].volume_db = volume_db
	sfx_players[0].play()

func play_sfx_from_path(path: String, volume_db: float = 0.0) -> void:
	var stream = load(path) as AudioStream
	play_sfx(stream, volume_db)

func play_music(stream: AudioStream, fade_time: float = 1.0) -> void:
	if stream == null:
		return
	if music_player.playing:
		var tween = create_tween()
		tween.tween_property(music_player, "volume_db", -40.0, fade_time * 0.5)
		await tween.finished
	music_player.stream = stream
	music_player.volume_db = 0.0
	music_player.play()
	if fade_time > 0.0:
		music_player.volume_db = -40.0
		var tween = create_tween()
		tween.tween_property(music_player, "volume_db", 0.0, fade_time * 0.5)

func stop_music(fade_time: float = 0.5) -> void:
	if not music_player.playing:
		return
	var tween = create_tween()
	tween.tween_property(music_player, "volume_db", -40.0, fade_time)
	await tween.finished
	music_player.stop()
