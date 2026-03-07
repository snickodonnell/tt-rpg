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

func _assert_true(condition: bool, message: String, failures: Array[String]) -> void:
	if not condition:
		failures.append(message)

func _assert_equal(actual, expected, message: String, failures: Array[String]) -> void:
	if actual != expected:
		failures.append("%s (expected %s, got %s)" % [message, str(expected), str(actual)])
