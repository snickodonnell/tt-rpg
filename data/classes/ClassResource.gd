@tool
extends TTResource
class_name ClassResource

@export var hit_die: String = "d10"
@export var saving_throw_proficiencies: Array[String] = []
@export var skill_proficiency_count: int = 2
@export var armor_proficiencies: Array[String] = []
@export var weapon_proficiencies: Array[String] = []
@export var modifiers: Array[StatModifier] = []
