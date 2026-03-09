@tool
extends TTResource
class_name BackgroundResource

@export var skill_proficiencies: Array[String] = []
@export var starting_gold_dice: String = ""          # e.g. "2d4 × 10 gp" or empty if using equipment package
@export var starting_equipment_options: Array[String] = []  # resource_ids of packs or individual items
@export var feature: BackgroundFeatureResource
@export var modifiers: Array[StatModifier] = []
@export var language_proficiencies: Array[String] = []
@export var language_choice_count: int = 0
@export var language_choice_options: Array[String] = []
@export var tool_proficiencies: Array[String] = []
@export var tool_choice_groups: Array[Dictionary] = []
