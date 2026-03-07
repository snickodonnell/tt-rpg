extends Node

const CHARACTER_CREATION_TESTS = preload("res://tests/character_creation/character_creation_tests.gd")

func _ready() -> void:
	var suite = CHARACTER_CREATION_TESTS.new()
	var failures: Array[String] = suite.run()

	if failures.is_empty():
		print("PASS: character creation smoke/regression tests")
		get_tree().quit(0)
		return

	for failure in failures:
		printerr("FAIL: ", failure)

	get_tree().quit(1)
