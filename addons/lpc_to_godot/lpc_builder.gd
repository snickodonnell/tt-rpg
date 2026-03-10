@tool
extends RefCounted

const DEFAULT_CONFIG := {
	"cast_frames": 7,
	"thrust_frames": 8,
	"idle_frames": 1,
	"walk_frames": 8,
	"slash_frames": 6,
	"shoot_frames": 13,
	"hurt_frames": 6,
	"framerate": 10,
}

const ANIMATION_ROWS := {
	"cast_up": 0,
	"cast_left": 1,
	"cast_down": 2,
	"cast_right": 3,
	"thrust_up": 4,
	"thrust_left": 5,
	"thrust_down": 6,
	"thrust_right": 7,
	"walk_up": 8,
	"walk_left": 9,
	"walk_down": 10,
	"walk_right": 11,
	"slash_up": 12,
	"slash_left": 13,
	"slash_down": 14,
	"slash_right": 15,
	"shoot_up": 16,
	"shoot_left": 17,
	"shoot_down": 18,
	"shoot_right": 19,
	"hurt_down": 20,
}

const ANIMATION_GROUPS := {
	"cast": ["cast_up", "cast_left", "cast_down", "cast_right"],
	"thrust": ["thrust_up", "thrust_left", "thrust_down", "thrust_right"],
	"idle": ["idle_up", "idle_left", "idle_down", "idle_right"],
	"walk": ["walk_up", "walk_left", "walk_down", "walk_right"],
	"slash": ["slash_up", "slash_left", "slash_down", "slash_right"],
	"shoot": ["shoot_up", "shoot_left", "shoot_down", "shoot_right"],
	"hurt": ["hurt_down"],
}

const FRAME_COUNTS := {
	"cast": "cast_frames",
	"thrust": "thrust_frames",
	"idle": "idle_frames",
	"walk": "walk_frames",
	"slash": "slash_frames",
	"shoot": "shoot_frames",
	"hurt": "hurt_frames",
}

const FRAME_SIZE := Vector2(64, 64)


static func generate_sprite_frames(spritesheet_path: String, options: Dictionary = {}) -> SpriteFrames:
	var spritesheet := load(spritesheet_path) as Texture2D
	if spritesheet == null:
		push_error("Failed to load LPC spritesheet: %s" % spritesheet_path)
		return null

	var config := DEFAULT_CONFIG.duplicate(true)
	for key in options.keys():
		config[key] = options[key]

	var frames := SpriteFrames.new()
	if frames.has_animation("default"):
		frames.remove_animation("default")

	for group_name in ANIMATION_GROUPS.keys():
		var frame_count := int(config.get(FRAME_COUNTS[group_name], 0))
		for animation_name in ANIMATION_GROUPS[group_name]:
			_add_animation(frames, spritesheet, animation_name, frame_count, int(config.get("framerate", 10)))

	return frames


static func save_sprite_frames(output_path: String, frames: SpriteFrames) -> int:
	return ResourceSaver.save(frames, output_path)


static func _add_animation(frames: SpriteFrames, spritesheet: Texture2D, animation_name: String, frame_count: int, framerate: int) -> void:
	if frames.has_animation(animation_name):
		frames.remove_animation(animation_name)

	frames.add_animation(animation_name)
	frames.set_animation_speed(animation_name, framerate)
	frames.set_animation_loop(animation_name, true)

	var row := int(ANIMATION_ROWS.get(animation_name, -1))
	if row < 0:
		return

	for column in range(frame_count):
		# LTG skips the duplicated first walk frame in LPC sheets.
		if animation_name.begins_with("walk_") and column == 0:
			continue

		var frame := AtlasTexture.new()
		frame.atlas = spritesheet
		frame.region = Rect2(FRAME_SIZE.x * column, FRAME_SIZE.y * row, FRAME_SIZE.x, FRAME_SIZE.y)
		frames.add_frame(animation_name, frame)
