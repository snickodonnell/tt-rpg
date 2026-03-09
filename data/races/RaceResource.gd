@tool
extends TTResource
class_name RaceResource

@export var size: String = "Medium"
@export var speed: int = 30
@export var darkvision: bool = false
@export var ability_increases: Dictionary = {}  # 2014 RAW style: {"str": 2, "con": 1}
@export var modifiers: Array[StatModifier] = []
@export var languages: Array[String] = ["common"]
@export var language_choice_count: int = 0
@export var language_choice_options: Array[String] = []
