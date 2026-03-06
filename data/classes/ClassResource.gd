@tool
extends TTResource
class_name ClassResource

@export var hit_die: String = "d10"
@export var saving_throw_proficiencies: Array[String] = []
@export var skill_proficiency_count: int = 2
@export var armor_proficiencies: Array[String] = []
@export var weapon_proficiencies: Array[String] = []
@export var spellcasting_ability: String = ""       # "int", "wis", "cha", or empty
@export var cantrips_known: int = 0
@export var spells_known_per_level: Dictionary = {} # e.g. {1: 2, 2: 3} for prepared casters
@export var modifiers: Array[StatModifier] = []
