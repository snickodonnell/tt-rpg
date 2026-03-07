@tool
extends TTResource
class_name BackgroundResource

@export var skill_proficiencies: Array[String] = []
@export var starting_gold_dice: String = ""          # e.g. "2d4 × 10 gp" or empty if using equipment package
@export var starting_equipment_options: Array[String] = []  # resource_ids of packs or individual items
@export var feature: BackgroundFeatureResource
@export var modifiers: Array[StatModifier] = []
