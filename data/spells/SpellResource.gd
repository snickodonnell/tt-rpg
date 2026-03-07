@tool
extends TTResource
class_name SpellResource

@export var spell_level: int = 0                    # 0 = cantrip
@export var school: String = "Evocation"
@export var casting_time: String = "1 action"
@export var spell_range: String = "30 feet"
@export var components: String = "V, S, M"
@export var duration: String = "Instantaneous"
@export var spell_lists: Array[String] = []         # e.g. ["class_wizard", "class_sorcerer"]
@export var spell_text: String = ""                 # renamed to avoid inheritance conflict
@export var higher_levels: String = ""              # Scaling text
@export var scaling: Dictionary = {}                # programmatic scaling, e.g. {"damage": "1d10 + floor((caster_level-1)/5)*1d10", "targets": "1 + floor((caster_level-1)/5)"}
@export var modifiers: Array[StatModifier] = []     # For spells that grant bonuses
