extends Node2D

const ROOM_SIZE := Vector2i(10, 10)
const FLOOR_TILE := Vector2i(0, 0)
const WALL_TILE := Vector2i(1, 0)
const TILE_SOURCE_ID := 0
const PLAYER_START_CELL := Vector2i(4, 4)

@onready var floor: TileMapLayer = $Floor
@onready var walls: TileMapLayer = $Walls
@onready var player: Node2D = $YSort/Player


func _ready() -> void:
	_paint_test_room()
	_place_player_in_room()


func _paint_test_room() -> void:
	floor.clear()
	walls.clear()

	for x in range(ROOM_SIZE.x):
		for y in range(ROOM_SIZE.y):
			var cell := Vector2i(x, y)
			floor.set_cell(cell, TILE_SOURCE_ID, FLOOR_TILE)
			if x == 0 or y == 0 or x == ROOM_SIZE.x - 1 or y == ROOM_SIZE.y - 1:
				walls.set_cell(cell, TILE_SOURCE_ID, WALL_TILE)


func _place_player_in_room() -> void:
	var start_position := floor.map_to_local(PLAYER_START_CELL)
	player.position = start_position
	player.set("target_position", start_position)
	player.set("grid_position", PLAYER_START_CELL)


func is_cell_walkable(cell: Vector2i) -> bool:
	return floor.get_cell_source_id(cell) != -1 and walls.get_cell_source_id(cell) == -1
