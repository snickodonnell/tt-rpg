@tool
extends Node

@export var current_character: CharacterSheetResource

const POINT_BUY_COSTS = {8:0,9:1,10:2,11:3,12:4,13:5,14:7,15:9}

func validate_point_buy(base_scores: Dictionary) -> bool:
	var total = 0
	for score in base_scores.values():
		total += POINT_BUY_COSTS.get(score, 999)
	return total <= 27

func create_character(race: RaceResource, class_res: ClassResource, background: BackgroundResource, base_ability_scores: Dictionary, character_name: String = "Hero", feats: Array[FeatResource] = [], equipment: Array[String] = []) -> CharacterSheetResource:
	var char_sheet = CharacterSheetResource.new()
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
	apply_feats(feats)

	# HP already handled by you
	var con_mod = AbilitySystem.get_modifier(base_ability_scores["con"])
	char_sheet.current_hp = class_res.hit_points_at_1st_level + con_mod
	char_sheet.current_level = 1

	# Starting equipment
	apply_starting_equipment(equipment)

	return char_sheet

func print_character_sheet():
	if not current_character: 
		print("No character created yet")
		return
	print("=== CHARACTER SHEET ===")
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

func apply_spells(_caster_class: ClassResource):
	# Placeholder - will populate spell lists for casters
	pass  # We'll expand this when we do the spell selection step

func apply_feats(feats: Array[FeatResource]):
	if not current_character:
		return
	for feat in feats:
		if not feat:
			continue
		current_character.feats.append(feat)
		if feat.modifiers:
			current_character.modifiers.append_array(feat.modifiers)

func apply_starting_equipment(equipment_ids: Array[String]):
	if not current_character:
		return
	for item_id in equipment_ids:
		var path = "res://data/items/" + item_id + ".tres"
		var item = load(path)
		if item:
			current_character.inventory.append(item)

func get_ability_modifier(ability_key: String) -> int:
	if current_character and current_character.base_ability_scores.has(ability_key):
		return AbilitySystem.get_modifier(current_character.base_ability_scores[ability_key])
	return 0


func save_current_character() -> Dictionary:
	if current_character == null:
		return {"success": false, "path": "", "error": ERR_INVALID_DATA}

	var save_dir := "user://characters"
	var dir_error := DirAccess.make_dir_recursive_absolute(save_dir)
	if dir_error != OK and dir_error != ERR_ALREADY_EXISTS:
		return {"success": false, "path": "", "error": dir_error}

	var save_path := "%s/%s.tres" % [save_dir, _build_character_save_file_name(current_character)]
	var save_error := ResourceSaver.save(current_character, save_path)
	return {
		"success": save_error == OK,
		"path": save_path,
		"error": save_error,
	}


func _build_character_save_file_name(character: CharacterSheetResource) -> String:
	var base_name := _sanitize_file_component(character.character_name if character != null else "")
	var timestamp := str(Time.get_unix_time_from_system())
	return "%s_%s" % [base_name, timestamp]


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
