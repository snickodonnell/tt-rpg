extends Node


func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventKey and event.pressed and not event.echo and event.alt_pressed and event.keycode == KEY_T:
		var manager := get_parent()
		if manager != null and manager.has_method("apply_debug_test_build"):
			manager.apply_debug_test_build()
			get_viewport().set_input_as_handled()
