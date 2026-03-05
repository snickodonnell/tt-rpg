@tool
extends Resource
class_name StatModifier

enum Type { ABILITY_SCORE, PROFICIENCY, AC, HP, SPEED, DAMAGE, SAVE, SKILL }

@export var modifier_type: Type
@export var target_key: String = ""           # "str", "skill_athletics", "ac", etc.
@export var value: int = 0
@export var source: String = ""               # "race_human", "item_sword", etc.
@export var condition: String = ""            # Optional
