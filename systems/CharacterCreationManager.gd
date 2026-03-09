@tool
extends Node

@export var current_character: CharacterSheetResource

const SAVE_GAME_RESOURCE_SCRIPT = preload("res://data/save/SaveGameResource.gd")
const SAVE_INDEX_RESOURCE_SCRIPT = preload("res://data/save/SaveIndexResource.gd")
const DEFAULT_CHARACTER_SAVE_NAME := "player_character"
const SAVE_ROOT := "user://saves"
const SAVE_RECORD_ROOT := "%s/records" % SAVE_ROOT
const SAVE_INDEX_PATH := "%s/index.tres" % SAVE_ROOT
const SAVE_KIND_MANUAL := "manual"
const SAVE_KIND_QUICKSAVE := "quicksave"
const SAVE_KIND_CHECKPOINT := "checkpoint"
const POINT_BUY_COSTS := {8: 0, 9: 1, 10: 2, 11: 3, 12: 4, 13: 5, 14: 7, 15: 9}

var current_save_id := ""
var current_slot_name := ""


func validate_point_buy(base_scores: Dictionary) -> bool:
	var total := 0
	for score in base_scores.values():
		total += POINT_BUY_COSTS.get(score, 999)
	return total <= 27


func create_character(race: RaceResource, class_res: ClassResource, background: BackgroundResource, base_ability_scores: Dictionary, character_name: String = "Hero", feats: Array[FeatResource] = [], equipment: Array[String] = []) -> CharacterSheetResource:
	var char_sheet := CharacterSheetResource.new()
	_ensure_character_identity(char_sheet)
	char_sheet.character_name = character_name
	char_sheet.race = race
	char_sheet.class_resource = class_res
	char_sheet.background = background
	char_sheet.base_ability_scores = base_ability_scores.duplicate()
	char_sheet.feats.clear()
	char_sheet.inventory.clear()

	# Apply modifiers
	char_sheet.modifiers.clear()
	char_sheet.modifiers.append_array(race.modifiers)
	char_sheet.modifiers.append_array(class_res.modifiers)
	char_sheet.modifiers.append_array(background.modifiers)

	current_character = char_sheet
	current_save_id = ""
	current_slot_name = ""
	apply_feats(feats)

	var con_mod := AbilitySystem.get_modifier(base_ability_scores["con"])
	char_sheet.current_hp = class_res.hit_points_at_1st_level + con_mod
	char_sheet.current_level = 1

	apply_starting_equipment(equipment)
	return char_sheet


func print_character_sheet() -> void:
	if not current_character:
		print("No character created yet")
		return
	print("=== CHARACTER SHEET ===")
	print("Character ID: ", current_character.character_id)
	print("Campaign ID: ", current_character.campaign_id if not current_character.campaign_id.is_empty() else "None")
	print("Active Save ID: ", current_save_id if not current_save_id.is_empty() else "None")
	print("Name: ", current_character.character_name)
	print("Race: ", current_character.race.display_name if current_character.race else "None")
	print("Class: ", current_character.class_resource.display_name if current_character.class_resource else "None")
	print("Background: ", current_character.background.display_name if current_character.background else "None")
	print("HP: ", current_character.current_hp)
	print("Base Scores: ", current_character.base_ability_scores)
	var feat_names: Array[String] = []
	for feat in current_character.feats:
		if feat:
			feat_names.append(feat.display_name)
	print("Feats: ", feat_names if not feat_names.is_empty() else ["None"])
	var equipment_names := _get_inventory_display_entries(current_character.inventory)
	print("Equipment: ", equipment_names if not equipment_names.is_empty() else ["None"])
	print("======================")


func apply_spells(_caster_class: ClassResource) -> void:
	pass


func apply_feats(feats: Array[FeatResource]) -> void:
	if not current_character:
		return
	for feat in feats:
		if not feat:
			continue
		current_character.feats.append(feat)
		if feat.modifiers:
			current_character.modifiers.append_array(feat.modifiers)


func apply_starting_equipment(equipment_ids: Array[String]) -> void:
	if not current_character:
		return
	for item_id in equipment_ids:
		var path := "res://data/items/%s.tres" % item_id
		var item := load(path)
		if item:
			current_character.inventory.append(item)


func get_ability_modifier(ability_key: String) -> int:
	if current_character and current_character.base_ability_scores.has(ability_key):
		return AbilitySystem.get_modifier(current_character.base_ability_scores[ability_key])
	return 0


func save_character(save_name: String = DEFAULT_CHARACTER_SAVE_NAME, save_kind: String = SAVE_KIND_MANUAL, display_name: String = "") -> Dictionary:
	if current_character == null:
		return {"success": false, "path": "", "error": ERR_INVALID_DATA, "save_name": "", "save_id": ""}

	_ensure_character_identity(current_character)
	var slot_name := _sanitize_file_component(save_name)
	var save_record = _build_save_record(current_character, slot_name, save_kind, display_name)
	var save_result := _write_save_record(save_record)
	if not bool(save_result.get("success", false)):
		return save_result

	var save_index = _load_save_index()
	_upsert_save_summary(save_index, _build_save_summary(save_record, str(save_result.get("path", ""))))
	save_index.slot_heads[slot_name] = save_record.save_id
	save_index.character_heads[save_record.character_id] = save_record.save_id
	if not save_record.campaign_id.is_empty():
		save_index.campaign_heads[save_record.campaign_id] = save_record.save_id

	var index_error := _save_save_index(save_index)
	if index_error != OK:
		return {
			"success": false,
			"path": str(save_result.get("path", "")),
			"error": index_error,
			"save_name": slot_name,
			"save_id": save_record.save_id,
			"character_id": save_record.character_id,
			"parent_save_id": save_record.parent_save_id,
			"campaign_id": save_record.campaign_id,
		}

	current_save_id = save_record.save_id
	current_slot_name = slot_name
	print("Character saved to record: ", save_result.get("path", ""))
	return {
		"success": true,
		"path": str(save_result.get("path", "")),
		"error": OK,
		"save_name": slot_name,
		"save_id": save_record.save_id,
		"character_id": save_record.character_id,
		"parent_save_id": save_record.parent_save_id,
		"campaign_id": save_record.campaign_id,
	}


func load_character(save_name: String = DEFAULT_CHARACTER_SAVE_NAME) -> CharacterSheetResource:
	var save_path := get_character_save_path(save_name)
	if save_path.is_empty():
		print("No character save found for slot: ", _sanitize_file_component(save_name))
		return null

	var save_record = ResourceLoader.load(save_path, "", ResourceLoader.CACHE_MODE_IGNORE)
	if save_record == null:
		push_error("Failed to load character save at: %s" % save_path)
		return null
	return _activate_loaded_save(save_record)


func load_test_character() -> CharacterSheetResource:
	var test_path := "res://data/test/TestCharacter.tres"
	if not ResourceLoader.exists(test_path):
		return null

	current_character = ResourceLoader.load(test_path, "", ResourceLoader.CACHE_MODE_IGNORE) as CharacterSheetResource
	current_save_id = ""
	current_slot_name = ""
	if current_character != null:
		_ensure_character_identity(current_character)
		print("Loaded test character: ", current_character.character_name)
	return current_character


func load_character_by_save_id(save_id: String) -> CharacterSheetResource:
	var normalized_save_id := save_id.strip_edges()
	if normalized_save_id.is_empty():
		return null

	var save_record = _load_save_record(normalized_save_id)
	if save_record == null:
		print("No save record found for ID: ", normalized_save_id)
		return null
	return _activate_loaded_save(save_record)


func has_character_save(save_name: String = DEFAULT_CHARACTER_SAVE_NAME) -> bool:
	return not _get_slot_head_save_id(save_name).is_empty()


func get_character_save_path(save_name: String = DEFAULT_CHARACTER_SAVE_NAME) -> String:
	var save_id := _get_slot_head_save_id(save_name)
	if save_id.is_empty():
		return ""
	return _get_save_record_path(save_id)


func save_current_character() -> Dictionary:
	if current_character == null:
		return {"success": false, "path": "", "error": ERR_INVALID_DATA, "save_id": ""}

	_ensure_character_identity(current_character)
	var save_record = _build_save_record(
		current_character,
		"",
		SAVE_KIND_CHECKPOINT,
		_build_character_snapshot_label(current_character)
	)
	var save_result := _write_save_record(save_record)
	if not bool(save_result.get("success", false)):
		return save_result

	var save_index = _load_save_index()
	_upsert_save_summary(save_index, _build_save_summary(save_record, str(save_result.get("path", ""))))
	save_index.character_heads[save_record.character_id] = save_record.save_id
	if not save_record.campaign_id.is_empty():
		save_index.campaign_heads[save_record.campaign_id] = save_record.save_id

	var index_error := _save_save_index(save_index)
	if index_error != OK:
		return {
			"success": false,
			"path": str(save_result.get("path", "")),
			"error": index_error,
			"save_id": save_record.save_id,
			"character_id": save_record.character_id,
			"parent_save_id": save_record.parent_save_id,
		}

	current_save_id = save_record.save_id
	current_slot_name = ""
	return {
		"success": true,
		"path": str(save_result.get("path", "")),
		"error": OK,
		"save_id": save_record.save_id,
		"character_id": save_record.character_id,
		"parent_save_id": save_record.parent_save_id,
	}


func list_save_records(character_id: String = "", campaign_id: String = "", slot_name: String = "") -> Array[Dictionary]:
	var save_index = _load_save_index()
	var normalized_character_id := character_id.strip_edges()
	var normalized_campaign_id := campaign_id.strip_edges()
	var normalized_slot_name := _sanitize_file_component(slot_name) if not slot_name.strip_edges().is_empty() else ""
	var results: Array[Dictionary] = []

	for entry in save_index.save_records:
		var summary := _normalize_save_summary(entry)
		if not normalized_character_id.is_empty() and str(summary.get("character_id", "")) != normalized_character_id:
			continue
		if not normalized_campaign_id.is_empty() and str(summary.get("campaign_id", "")) != normalized_campaign_id:
			continue
		if not normalized_slot_name.is_empty() and str(summary.get("slot_name", "")) != normalized_slot_name:
			continue
		results.append(summary)

	results.sort_custom(func(left: Dictionary, right: Dictionary) -> bool:
		return int(left.get("created_at_unix", 0)) > int(right.get("created_at_unix", 0))
	)
	return results


func get_current_save_id() -> String:
	return current_save_id


func _build_save_record(character: CharacterSheetResource, slot_name: String, save_kind: String, display_name: String):
	var snapshot := character.duplicate(true) as CharacterSheetResource
	if snapshot == null:
		snapshot = character

	_ensure_character_identity(snapshot)
	if current_character != null and current_character.character_id != snapshot.character_id:
		current_character.character_id = snapshot.character_id
	if current_character != null and snapshot.campaign_id != current_character.campaign_id:
		current_character.campaign_id = snapshot.campaign_id

	var save_record = SAVE_GAME_RESOURCE_SCRIPT.new()
	save_record.save_id = _generate_uuid()
	save_record.resource_id = save_record.save_id
	save_record.parent_save_id = current_save_id
	save_record.character_id = snapshot.character_id
	save_record.campaign_id = snapshot.campaign_id
	save_record.slot_name = slot_name
	save_record.save_kind = save_kind
	save_record.created_at_unix = int(Time.get_unix_time_from_system())
	save_record.character_name = snapshot.character_name
	save_record.character_level = snapshot.current_level
	save_record.display_name = display_name if not display_name.strip_edges().is_empty() else _build_default_save_display_name(snapshot, slot_name, save_kind)
	save_record.character_state = snapshot
	return save_record


func _build_default_save_display_name(character: CharacterSheetResource, slot_name: String, save_kind: String) -> String:
	var name := character.character_name.strip_edges()
	if name.is_empty():
		name = "Unnamed Character"
	if not slot_name.is_empty():
		return "%s (%s)" % [name, slot_name]
	if save_kind == SAVE_KIND_CHECKPOINT:
		return "%s Checkpoint" % name
	return name


func _activate_loaded_save(save_record) -> CharacterSheetResource:
	if save_record == null or save_record.character_state == null:
		return null

	var loaded_character := save_record.character_state.duplicate(true) as CharacterSheetResource
	if loaded_character == null:
		push_error("Loaded save record did not contain a valid character snapshot.")
		return null

	_ensure_character_identity(loaded_character)
	if loaded_character.campaign_id.is_empty():
		loaded_character.campaign_id = save_record.campaign_id

	current_character = loaded_character
	current_save_id = save_record.save_id
	current_slot_name = save_record.slot_name
	print("Character loaded from save record: ", save_record.save_id)
	return current_character


func _write_save_record(save_record) -> Dictionary:
	var dir_error := _ensure_save_directory(SAVE_RECORD_ROOT)
	if dir_error != OK:
		return {"success": false, "path": "", "error": dir_error, "save_id": save_record.save_id}

	var save_path := _get_save_record_path(save_record.save_id)
	var save_error := ResourceSaver.save(save_record, save_path)
	return {
		"success": save_error == OK,
		"path": save_path,
		"error": save_error,
		"save_id": save_record.save_id,
	}


func _load_save_record(save_id: String):
	var save_path := _get_save_record_path(save_id)
	if not ResourceLoader.exists(save_path):
		return null
	return ResourceLoader.load(save_path, "", ResourceLoader.CACHE_MODE_IGNORE)


func _load_save_index():
	if ResourceLoader.exists(SAVE_INDEX_PATH):
		var loaded_index = ResourceLoader.load(SAVE_INDEX_PATH, "", ResourceLoader.CACHE_MODE_IGNORE)
		if loaded_index != null:
			_normalize_save_index(loaded_index)
			return loaded_index

	var save_index = SAVE_INDEX_RESOURCE_SCRIPT.new()
	_normalize_save_index(save_index)
	return save_index


func _save_save_index(save_index) -> int:
	var dir_error := _ensure_save_directory(SAVE_ROOT)
	if dir_error != OK:
		return dir_error
	return ResourceSaver.save(save_index, SAVE_INDEX_PATH)


func _normalize_save_index(save_index) -> void:
	if save_index == null:
		return
	if save_index.save_records == null:
		save_index.save_records = []
	if save_index.slot_heads == null:
		save_index.slot_heads = {}
	if save_index.character_heads == null:
		save_index.character_heads = {}
	if save_index.campaign_heads == null:
		save_index.campaign_heads = {}


func _upsert_save_summary(save_index, summary: Dictionary) -> void:
	var updated_records: Array[Dictionary] = []
	var updated := false
	for entry in save_index.save_records:
		var existing := _normalize_save_summary(entry)
		if str(existing.get("save_id", "")) == str(summary.get("save_id", "")):
			updated_records.append(summary.duplicate(true))
			updated = true
		else:
			updated_records.append(existing)
	if not updated:
		updated_records.append(summary.duplicate(true))
	save_index.save_records = updated_records


func _build_save_summary(save_record, save_path: String) -> Dictionary:
	return {
		"save_id": save_record.save_id,
		"parent_save_id": save_record.parent_save_id,
		"character_id": save_record.character_id,
		"campaign_id": save_record.campaign_id,
		"slot_name": save_record.slot_name,
		"save_kind": save_record.save_kind,
		"created_at_unix": save_record.created_at_unix,
		"path": save_path,
		"display_name": save_record.display_name,
		"character_name": save_record.character_name,
		"character_level": save_record.character_level,
	}


func _normalize_save_summary(entry: Dictionary) -> Dictionary:
	return {
		"save_id": str(entry.get("save_id", "")),
		"parent_save_id": str(entry.get("parent_save_id", "")),
		"character_id": str(entry.get("character_id", "")),
		"campaign_id": str(entry.get("campaign_id", "")),
		"slot_name": str(entry.get("slot_name", "")),
		"save_kind": str(entry.get("save_kind", SAVE_KIND_MANUAL)),
		"created_at_unix": int(entry.get("created_at_unix", 0)),
		"path": str(entry.get("path", "")),
		"display_name": str(entry.get("display_name", "")),
		"character_name": str(entry.get("character_name", "")),
		"character_level": int(entry.get("character_level", 1)),
	}


func _get_slot_head_save_id(save_name: String) -> String:
	var normalized_name := _sanitize_file_component(save_name)
	var save_index = _load_save_index()
	return str(save_index.slot_heads.get(normalized_name, ""))


func _get_save_record_path(save_id: String) -> String:
	return "%s/%s.tres" % [SAVE_RECORD_ROOT, save_id]


func _build_character_snapshot_label(character: CharacterSheetResource) -> String:
	var base_name := _sanitize_file_component(character.character_name if character != null else "")
	var timestamp := str(Time.get_unix_time_from_system())
	return "%s_%s" % [base_name, timestamp]


func _ensure_character_identity(character: CharacterSheetResource) -> void:
	if character == null:
		return
	if character.character_id.strip_edges().is_empty():
		character.character_id = _generate_uuid()


func _generate_uuid() -> String:
	var rng := RandomNumberGenerator.new()
	rng.randomize()
	var segments := [8, 4, 4, 4, 12]
	var values: Array[String] = []
	for segment_length in segments:
		var segment := ""
		for index in range(segment_length):
			var nibble := rng.randi_range(0, 15)
			segment += "0123456789abcdef"[nibble]
		values.append(segment)
	return "%s-%s-%s-%s-%s" % [values[0], values[1], values[2], values[3], values[4]]


func _ensure_save_directory(directory_path: String) -> int:
	var dir_error := DirAccess.make_dir_recursive_absolute(directory_path)
	if dir_error == OK or dir_error == ERR_ALREADY_EXISTS:
		return OK
	return dir_error


func _sanitize_file_component(value: String) -> String:
	var sanitized := ""
	for character in value.to_lower():
		var code := character.unicode_at(0)
		var is_letter := code >= 97 and code <= 122
		var is_number := code >= 48 and code <= 57
		if is_letter or is_number:
			sanitized += character
		elif character == " " or character == "-" or character == "_":
			if sanitized.is_empty() or sanitized.ends_with("_"):
				continue
			sanitized += "_"

	sanitized = sanitized.strip_edges()
	sanitized = sanitized.trim_suffix("_")
	if sanitized.is_empty():
		return "character"
	return sanitized


func _get_inventory_display_entries(inventory: Array[ItemResource]) -> Array[String]:
	var entries: Array[String] = []
	var counts := {}
	var ordered_keys: Array[String] = []
	var names := {}
	var quantity_regex := RegEx.new()
	quantity_regex.compile("^(.*)\\((\\d+)\\)\\s*$")

	for item in inventory:
		if item == null:
			continue

		var display_name := item.display_name
		var stack_name := display_name
		var quantity := 1
		var quantity_match := quantity_regex.search(display_name)
		if quantity_match != null:
			stack_name = quantity_match.get_string(1).strip_edges()
			quantity = max(int(quantity_match.get_string(2)), 1)

		var stack_key := "%s::%s" % [item.resource_id, stack_name]
		if not counts.has(stack_key):
			counts[stack_key] = 0
			ordered_keys.append(stack_key)
			names[stack_key] = stack_name
		counts[stack_key] = int(counts[stack_key]) + quantity

	for stack_key in ordered_keys:
		var total_quantity := int(counts.get(stack_key, 0))
		var stack_name := str(names.get(stack_key, stack_key))
		if total_quantity > 1:
			entries.append("%s x%d" % [stack_name, total_quantity])
		else:
			entries.append(stack_name)

	return entries
