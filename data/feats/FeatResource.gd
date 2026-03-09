@tool
extends TTResource
class_name FeatResource

@export var prerequisites: String = ""          # e.g. "Strength 13" or "Fighter level 4"
@export var modifiers: Array[StatModifier] = [] # ability bonuses, proficiencies, AC, etc.
@export var special_rules: String = ""          # for complex feats like Lucky or Sentinel
@export var language_proficiencies: Array[String] = []
@export var language_choice_count: int = 0
@export var language_choice_options: Array[String] = []
@export var tool_proficiencies: Array[String] = []
@export var tool_choice_groups: Array[Dictionary] = []
@export var flexible_proficiency_choice_count: int = 0
