extends RefCounted

const MANAGER_SCRIPT = preload("res://systems/CharacterCreationManager.gd")
const HUMAN_RACE = preload("res://data/races/race_human.tres")
const FIGHTER_CLASS = preload("res://data/classes/class_fighter.tres")
const SOLDIER_BACKGROUND = preload("res://data/backgrounds/background_soldier.tres")
const ALERT_FEAT = preload("res://data/feats/feat_alert.tres")

func run() -> Array[String]:
	var failures: Array[String] = []

	_test_point_buy_validation(failures)
	_test_create_character_smoke(failures)
	_test_ability_modifier_lookup(failures)
	_test_save_and_load_character_round_trip(failures)

	return failures

func _test_point_buy_validation(failures: Array[String]) -> void:
	var manager = MANAGER_SCRIPT.new()
	var valid_scores = {"str": 15, "dex": 14, "con": 13, "int": 10, "wis": 12, "cha": 8}
	var invalid_scores = {"str": 15, "dex": 15, "con": 15, "int": 15, "wis": 15, "cha": 15}

	_assert_true(manager.validate_point_buy(valid_scores), "27-point buy example should validate", failures)
	_assert_true(not manager.validate_point_buy(invalid_scores), "Overspent point buy should fail validation", failures)
	manager.free()

func _test_create_character_smoke(failures: Array[String]) -> void:
	var manager = MANAGER_SCRIPT.new()
	var test_scores = {"str": 15, "dex": 14, "con": 13, "int": 10, "wis": 12, "cha": 8}
	var test_feats: Array[FeatResource] = [ALERT_FEAT]
	var test_equipment: Array[String] = ["item_longsword", "item_chain_mail"]
	var char_sheet = manager.create_character(
		HUMAN_RACE,
		FIGHTER_CLASS,
		SOLDIER_BACKGROUND,
		test_scores,
		"TestHero",
		test_feats,
		test_equipment
	)

	_assert_equal(char_sheet.character_name, "TestHero", "Character name should be assigned", failures)
	_assert_equal(char_sheet.race.display_name, "Human", "Race should be assigned", failures)
	_assert_equal(char_sheet.class_resource.display_name, "Fighter", "Class should be assigned", failures)
	_assert_equal(char_sheet.background.display_name, "Soldier", "Background should be assigned", failures)
	_assert_equal(char_sheet.current_level, 1, "New characters should start at level 1", failures)
	_assert_equal(char_sheet.current_hp, 11, "Fighter HP should include first-level max die plus CON modifier", failures)
	_assert_equal(char_sheet.modifiers.size(), 1, "Feat modifiers should be applied", failures)
	_assert_equal(char_sheet.inventory.size(), 2, "Starting equipment should be added to inventory", failures)
	_assert_equal((char_sheet.inventory[0] as ItemResource).resource_id, "item_longsword", "First equipment item should load in order", failures)
	_assert_equal((char_sheet.inventory[1] as ItemResource).resource_id, "item_chain_mail", "Second equipment item should load in order", failures)
	manager.free()

func _test_ability_modifier_lookup(failures: Array[String]) -> void:
	var manager = MANAGER_SCRIPT.new()
	var test_scores = {"str": 15, "dex": 14, "con": 13, "int": 10, "wis": 12, "cha": 8}

	manager.create_character(HUMAN_RACE, FIGHTER_CLASS, SOLDIER_BACKGROUND, test_scores)

	_assert_equal(manager.get_ability_modifier("con"), 1, "CON modifier lookup should return 1 for score 13", failures)
	_assert_equal(manager.get_ability_modifier("cha"), -1, "CHA modifier lookup should return -1 for score 8", failures)
	_assert_equal(manager.get_ability_modifier("missing"), 0, "Unknown ability keys should return 0", failures)
	manager.free()


func _test_save_and_load_character_round_trip(failures: Array[String]) -> void:
	var manager = MANAGER_SCRIPT.new()
	var test_scores = {"str": 15, "dex": 14, "con": 13, "int": 10, "wis": 12, "cha": 8}
	var test_feats: Array[FeatResource] = [ALERT_FEAT]
	var test_equipment: Array[String] = ["item_longsword", "item_chain_mail"]
	var slot_name := "test_character_round_trip"
	var character := manager.create_character(
		HUMAN_RACE,
		FIGHTER_CLASS,
		SOLDIER_BACKGROUND,
		test_scores,
		"RoundTripHero",
		test_feats,
		test_equipment
	)
	character.gender = "female"

	var save_result: Dictionary = manager.save_character(slot_name)
	_assert_true(bool(save_result.get("success", false)), "Character slot save should succeed", failures)
	_assert_true(manager.has_character_save(slot_name), "Saved slot should be discoverable", failures)
	_assert_true(not str(save_result.get("save_id", "")).is_empty(), "Save records should get a generated save ID", failures)
	_assert_true(not str(save_result.get("character_id", "")).is_empty(), "Characters should get a generated character ID", failures)

	var first_save_id := str(save_result.get("save_id", ""))
	var first_character_id := str(save_result.get("character_id", ""))
	var loaded_latest := manager.load_character(slot_name)
	_assert_true(loaded_latest != null, "Saved character should load back from its slot", failures)
	if loaded_latest == null:
		manager.free()
		return

	_assert_equal(loaded_latest.character_name, "RoundTripHero", "Loaded character should preserve name", failures)
	_assert_equal(loaded_latest.gender, "female", "Loaded character should preserve gender", failures)
	_assert_equal(loaded_latest.current_hp, 11, "Loaded character should preserve hit points", failures)
	_assert_equal(loaded_latest.inventory.size(), 2, "Loaded character should preserve inventory", failures)
	_assert_equal(loaded_latest.feats.size(), 1, "Loaded character should preserve feats", failures)
	_assert_equal(loaded_latest.character_id, first_character_id, "Loaded character should preserve its stable character ID", failures)

	loaded_latest.current_level = 2
	loaded_latest.character_name = "RoundTripHero II"
	var second_save_result: Dictionary = manager.save_character(slot_name, "quicksave")
	_assert_true(bool(second_save_result.get("success", false)), "A second save record should succeed", failures)
	_assert_true(str(second_save_result.get("save_id", "")) != first_save_id, "A new save should create a distinct save record", failures)
	_assert_equal(str(second_save_result.get("parent_save_id", "")), first_save_id, "Later saves should point at the previously loaded save", failures)
	_assert_equal(str(second_save_result.get("character_id", "")), first_character_id, "Branch saves should keep the same character ID", failures)

	var history := manager.list_save_records(first_character_id)
	_assert_true(history.size() >= 2, "Save index should retain multiple save records per character", failures)
	if history.size() >= 2:
		_assert_equal(str(history[0].get("save_id", "")), str(second_save_result.get("save_id", "")), "Latest save should sort first in the index", failures)

	var original_branch := manager.load_character_by_save_id(first_save_id)
	_assert_true(original_branch != null, "Older save records should still be loadable by save ID", failures)
	if original_branch != null:
		_assert_equal(original_branch.current_level, 1, "Loading an earlier save should restore the earlier character state", failures)
		_assert_equal(original_branch.character_name, "RoundTripHero", "Earlier save should retain its original name", failures)

	var newest_branch := manager.load_character(slot_name)
	_assert_true(newest_branch != null, "Slot head should still resolve after multiple saves", failures)
	if newest_branch != null:
		_assert_equal(newest_branch.current_level, 2, "Loading the slot should resolve to the latest save record", failures)
		_assert_equal(newest_branch.character_name, "RoundTripHero II", "Latest slot load should return the newest branched state", failures)
	manager.free()

func _assert_true(condition: bool, message: String, failures: Array[String]) -> void:
	if not condition:
		failures.append(message)

func _assert_equal(actual, expected, message: String, failures: Array[String]) -> void:
	if actual != expected:
		failures.append("%s (expected %s, got %s)" % [message, str(expected), str(actual)])
