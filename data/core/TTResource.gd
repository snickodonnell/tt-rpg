@tool
extends Resource
class_name TTResource

@export var resource_id: String = ""          # snake_case, unique key
@export var display_name: String = ""
@export var description: String = ""          # Tooltip / character sheet text
@export var flavor_text: String = ""          # Optional lore
