@tool
extends TTResource
class_name FeatResource

@export var prerequisites: String = ""          # e.g. "Strength 13" or "Fighter level 4"
@export var modifiers: Array[StatModifier] = [] # ability bonuses, proficiencies, AC, etc.
@export var special_rules: String = ""          # for complex feats like Lucky or Sentinel
