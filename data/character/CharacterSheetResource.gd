@tool
extends TTResource
class_name CharacterSheetResource

@export var character_name: String = ""
@export var race: RaceResource
@export var class_resource: ClassResource
@export var classes: Array[Dictionary] = []  # e.g. [{"class_resource": ClassResource, "level": 1}]
@export var subclass: SubclassResource
@export var background: BackgroundResource
@export var base_ability_scores: Dictionary = {
    "str": 8, "dex": 8, "con": 8,
    "int": 8, "wis": 8, "cha": 8
}
@export var modifiers: Array[StatModifier] = []
@export var feats: Array[FeatResource] = []
@export var inventory: Array[ItemResource] = []
@export var equipped_items: Dictionary = {}
@export var current_level: int = 1
@export var current_hp: int = 10
@export var portrait_path: String = ""
