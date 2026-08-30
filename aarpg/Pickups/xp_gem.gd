class_name XpGem
extends PickupBase

@export var xp_amount: int = 5

@export_group("Magnet")
@export var magnet_radius: float = 70.0
@export var magnet_speed: float = 240.0
@export var magnet_accel: float = 900.0

var _magnet_velocity: Vector2 = Vector2.ZERO
var _target_player: Player = null


func _ready() -> void:
	bob_speed = 5.0
	bob_amplitude = 2.0
	bob_base_y = -4.0
	rotation_speed = 1.5
	lifetime = 15.0
	var size_scale := 1.0 + 0.04 * float(xp_amount)
	scale = Vector2(size_scale, size_scale)
	super._ready()
	_target_player = Player.find_in_tree(get_tree())
	_update_season_tint()


func _update_season_tint() -> void:
	match SeasonManager.current_season:
		SeasonManager.Season.SUMMER:
			modulate = Color(1.0, 0.85, 0.5)
		SeasonManager.Season.AUTUMN:
			modulate = Color(1.0, 0.7, 0.45)
		SeasonManager.Season.WINTER:
			modulate = Color(0.75, 0.9, 1.0)
		_:
			modulate = Color(1.0, 1.0, 1.0)

func _process(delta: float) -> void:
	super._process(delta)
	_process_magnet(delta)


func _process_magnet(delta: float) -> void:
	if collected or _target_player == null or not is_instance_valid(_target_player):
		return
	if _target_player.is_dead:
		return
	var to_player: Vector2 = _target_player.global_position - global_position
	var dist: float = to_player.length()
	if dist > _target_player.get_xp_magnet_radius(magnet_radius):
		return
	var dir := to_player / maxf(dist, 0.001)
	_magnet_velocity = _magnet_velocity.move_toward(dir * magnet_speed, magnet_accel * delta)
	global_position += _magnet_velocity * delta


func _draw() -> void:
	draw_circle(Vector2.ZERO, 5.5, Color(0.2, 0.65, 1.0))
	draw_circle(Vector2.ZERO, 3.0, Color(0.75, 0.92, 1.0))


func _apply_effect(player: Player) -> void:
	player.gain_xp(xp_amount)
	var applied := maxi(roundi(float(xp_amount) * player.get_xp_multiplier()), 1)
	_spawn_popup("+" + str(applied) + " XP", Color(0.35, 0.75, 1.0))
