extends CharacterBody2D

const SPEED := 200.0
const TILE_SIZE := Vector2(64.0, 32.0)

var character_data: CharacterSheetResource
var grid_position := Vector2i.ZERO
var target_position := Vector2.ZERO


func _ready() -> void:
	character_data = CharacterCreationManager.load_test_character()
	target_position = position
	if character_data == null:
		push_warning("Failed to load test character.")
		return

	print("Player loaded: %s" % character_data.character_name)
	print(
		"Stats: STR %d DEX %d CON %d INT %d WIS %d CHA %d" % [
			int(character_data.base_ability_scores.get("str", 0)),
			int(character_data.base_ability_scores.get("dex", 0)),
			int(character_data.base_ability_scores.get("con", 0)),
			int(character_data.base_ability_scores.get("int", 0)),
			int(character_data.base_ability_scores.get("wis", 0)),
			int(character_data.base_ability_scores.get("cha", 0)),
		]
	)


func _physics_process(delta: float) -> void:
	if position.distance_to(target_position) > 0.01:
		position = position.move_toward(target_position, SPEED * delta)
		return

	position = target_position
	var grid_step := _get_requested_step()
	if grid_step == Vector2i.ZERO:
		return

	var next_cell := grid_position + grid_step
	if not _can_move_to_cell(next_cell):
		return

	grid_position += grid_step
	target_position += _grid_to_world_offset(grid_step)


func _get_requested_step() -> Vector2i:
	if Input.is_physical_key_pressed(KEY_W):
		return Vector2i(0, -1)
	if Input.is_physical_key_pressed(KEY_S):
		return Vector2i(0, 1)
	if Input.is_physical_key_pressed(KEY_A):
		return Vector2i(-1, 0)
	if Input.is_physical_key_pressed(KEY_D):
		return Vector2i(1, 0)
	return Vector2i.ZERO


func _grid_to_world_offset(grid_step: Vector2i) -> Vector2:
	var half_tile := TILE_SIZE * 0.5
	return Vector2(
		(grid_step.x - grid_step.y) * half_tile.x,
		(grid_step.x + grid_step.y) * half_tile.y
	)


func _can_move_to_cell(cell: Vector2i) -> bool:
	var world := get_tree().current_scene
	if world != null and world.has_method("is_cell_walkable"):
		return bool(world.call("is_cell_walkable", cell))
	return true
