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
	var equipment_names: Array[String] = []
	for item in current_character.inventory:
		if item:
			equipment_names.append(item.display_name)
	print("Equipment: ", equipment_names if not equipment_names.is_empty() else ["None"])
	print("======================")

func apply_spells(caster_class: ClassResource):
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
