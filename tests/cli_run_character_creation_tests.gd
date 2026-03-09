extends SceneTree

const CHARACTER_CREATION_TESTS = preload("res://tests/character_creation/character_creation_tests.gd")


func _initialize() -> void:
	var suite = CHARACTER_CREATION_TESTS.new()
	var failures: Array[String] = suite.run()
	var output_lines: Array[String] = []

	if failures.is_empty():
		output_lines.append("PASS: character creation smoke/regression tests")
	else:
		for failure in failures:
			output_lines.append("FAIL: %s" % failure)

	for line in output_lines:
		print(line)

	var report := FileAccess.open("user://character_creation_test_results.txt", FileAccess.WRITE)
	if report != null:
		report.store_string("\n".join(output_lines))

	quit(0 if failures.is_empty() else 1)
