class_name MapPainter
extends Node2D

@export var floor_source_id: int = 0
@export var floor_atlas_region: Rect2i = Rect2i(0, 0, 16, 4)
@export var deco_source_id: int = -1
@export var deco_atlas_region: Rect2i = Rect2i(0, 0, 0, 0)
@export var paint_size: Vector2i = Vector2i(40, 24)
@export_range(0.0, 1.0) var decoration_density: float = 0.0
@export var rng_seed: int = 1337
@export var enable_bounds: bool = true

var _floor_tiles: Array[Vector2i] = []
var _deco_tiles: Array[Vector2i] = []


func _ready() -> void:
	_collect_tiles()
	var rng := RandomNumberGenerator.new()
	rng.seed = rng_seed
	for child in get_children():
		if child is TileMapLayer:
			_paint(child, rng)
			break
	if enable_bounds:
		_build_bounds()


func _collect_tiles() -> void:
	for y in floor_atlas_region.size.y:
		for x in floor_atlas_region.size.x:
			_floor_tiles.append(floor_atlas_region.position + Vector2i(x, y))
	for y in deco_atlas_region.size.y:
		for x in deco_atlas_region.size.x:
			_deco_tiles.append(deco_atlas_region.position + Vector2i(x, y))


func _paint(layer: TileMapLayer, rng: RandomNumberGenerator) -> void:
	for y in paint_size.y:
		for x in paint_size.x:
			var tile: Vector2i = _floor_tiles[rng.randi() % _floor_tiles.size()]
			layer.set_cell(Vector2i(x, y), floor_source_id, tile, 0)
	if deco_source_id >= 0 and _deco_tiles.size() > 0 and decoration_density > 0.0:
		for y in paint_size.y:
			for x in paint_size.x:
				if rng.randf() < decoration_density:
					var tile: Vector2i = _deco_tiles[rng.randi() % _deco_tiles.size()]
					layer.set_cell(Vector2i(x, y), deco_source_id, tile, 0)


func _build_bounds() -> void:
	var wall := StaticBody2D.new()
	wall.name = "Bounds"
	add_child(wall)
	var w: float = paint_size.x * 32.0
	var h: float = paint_size.y * 32.0
	_add_wall(wall, Vector2(w / 2.0, -8.0), Vector2(w + 32.0, 16.0))
	_add_wall(wall, Vector2(w / 2.0, h + 8.0), Vector2(w + 32.0, 16.0))
	_add_wall(wall, Vector2(-8.0, h / 2.0), Vector2(16.0, h + 32.0))
	_add_wall(wall, Vector2(w + 8.0, h / 2.0), Vector2(16.0, h + 32.0))


func _add_wall(wall: StaticBody2D, pos: Vector2, size: Vector2) -> void:
	var shape := CollisionShape2D.new()
	var rect := RectangleShape2D.new()
	rect.size = size
	shape.shape = rect
	shape.position = pos
	wall.add_child(shape)
