extends CharacterBody2D
class_name Player

var speed: float = 200.0

@onready var visual: ColorRect = $Visual


func _physics_process(delta: float) -> void:
	var direction: Vector2 = Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down")
	velocity = direction * speed
	move_and_slide()
