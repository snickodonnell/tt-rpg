extends Node

const CHARACTER_CREATION_TESTS = preload("res://tests/character_creation/character_creation_tests.gd")
const HUMAN_RACE = preload("res://data/races/race_human.tres")
const FIGHTER_CLASS = preload("res://data/classes/class_fighter.tres")
const SOLDIER_BACKGROUND = preload("res://data/backgrounds/background_soldier.tres")
const ALERT_FEAT = preload("res://data/feats/feat_alert.tres")

@export var run_on_play: bool = true
@export var print_character_sheet_output: bool = true
@export var load_prebuilt_test_character_on_play: bool = true

func _ready() -> void:
	if not run_on_play:
		return

	_run_character_creation_smoke_output()
	_run_prebuilt_test_character_output()
	_run_regression_suite()

func _run_character_creation_smoke_output() -> void:
	var test_scores = {"str": 15, "dex": 14, "con": 13, "int": 10, "wis": 12, "cha": 8}
	var test_feats: Array[FeatResource] = [ALERT_FEAT]
	var test_equipment: Array[String] = ["item_longsword", "item_chain_mail"]

	CharacterCreationManager.create_character(
		HUMAN_RACE,
		FIGHTER_CLASS,
		SOLDIER_BACKGROUND,
		test_scores,
		"TestHero",
		test_feats,
		test_equipment
	)

	if print_character_sheet_output:
		print("--- Manual Character Creation Smoke Test ---")
		CharacterCreationManager.print_character_sheet()


func _run_prebuilt_test_character_output() -> void:
	if not load_prebuilt_test_character_on_play:
		return

	var test_character := CharacterCreationManager.load_test_character()
	if test_character == null:
		printerr("FAIL: prebuilt test character could not be loaded")
		return

	if print_character_sheet_output:
		print("--- Prebuilt Test Character ---")
		CharacterCreationManager.print_character_sheet()

func _run_regression_suite() -> void:
	var suite = CHARACTER_CREATION_TESTS.new()
	var failures: Array[String] = suite.run()

	if failures.is_empty():
		print("PASS: character creation smoke/regression tests")
		return

	for failure in failures:
		printerr("FAIL: ", failure)
