extends Node

signal season_changed(season: int)

enum Season { SPRING, SUMMER, AUTUMN, WINTER }

const SEASON_NAMES: Array[String] = ["Spring", "Summer", "Autumn", "Winter"]

var current_season: int = Season.SPRING

var _last_scene: Node = null
var _weather: Array[Node] = []


func _ready() -> void:
	get_tree().node_added.connect(_on_node_added)


func _process(_delta: float) -> void:
	var scene := get_tree().current_scene
	if scene != _last_scene:
		_last_scene = scene
		_spawn_weather()


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("cycle_season"):
		cycle_season()


func cycle_season() -> void:
	current_season = (current_season + 1) % Season.size()
	_apply_tints()
	_spawn_weather()
	season_changed.emit(current_season)


func get_season_name() -> String:
	return SEASON_NAMES[current_season]


func get_outdoor_tint() -> Color:
	match current_season:
		Season.SUMMER:
			return Color(1.0, 0.92, 0.62)
		Season.AUTUMN:
			return Color(1.0, 0.55, 0.3)
		Season.WINTER:
			return Color(0.7, 0.82, 1.0)
	return Color(0.94, 1.05, 0.92)


func _on_node_added(node: Node) -> void:
	if node.is_in_group("outdoor_ground"):
		node.modulate = get_outdoor_tint()


func _apply_tints() -> void:
	for node in get_tree().get_nodes_in_group("outdoor_ground"):
		node.modulate = get_outdoor_tint()


func _spawn_weather() -> void:
	_clear_weather()
	if get_tree().get_nodes_in_group("outdoor_ground").is_empty():
		return
	match current_season:
		Season.AUTUMN:
			_create_particles(Color(0.95, 0.6, 0.2), Vector2(3, 5), 24.0, 110.0)
		Season.WINTER:
			_create_particles(Color(0.92, 0.96, 1.0), Vector2(2, 3), 12.0, 130.0)


func _create_particles(color: Color, scale_range: Vector2, velocity: float, gravity: float) -> void:
	var scene := get_tree().current_scene
	if scene == null:
		return
	var particles := CPUParticles2D.new()
	particles.name = "SeasonWeather"
	particles.z_index = 5
	particles.emitting = true
	particles.amount = 40
	particles.lifetime = 6.0
	particles.direction = Vector2(0, 1)
	particles.spread = 8.0
	particles.gravity = Vector2(0, gravity)
	particles.initial_velocity_min = velocity
	particles.initial_velocity_max = velocity + 40.0
	particles.scale_amount_min = scale_range.x
	particles.scale_amount_max = scale_range.y
	particles.color = color
	particles.emission_shape = CPUParticles2D.EMISSION_SHAPE_RECTANGLE
	particles.emission_rect_extents = Vector2(820, 140)
	particles.position = Vector2(768, 20)
	scene.add_child(particles)
	_weather.append(particles)


func _clear_weather() -> void:
	for node in _weather:
		if is_instance_valid(node):
			node.queue_free()
	_weather.clear()
