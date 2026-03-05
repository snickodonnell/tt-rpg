@tool
extends TTResource
class_name ItemResource

enum Slot { NONE, MAIN_HAND, OFF_HAND, ARMOR, HEAD, NECK, RING, BOOTS, BELT }

@export var slot: Slot
@export var cost_gp: int = 0
@export var weight_lb: float = 0.0
@export var modifiers: Array[StatModifier] = []
@export var is_equipped: bool = false
@export var requires_attunement: bool = false
