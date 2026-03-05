@tool
extends TTResource
class_name SubclassResource

@export var parent_class_id: String = ""  # e.g. "class_fighter"
@export var level_unlocked: int = 3
@export var modifiers: Array[StatModifier] = []
