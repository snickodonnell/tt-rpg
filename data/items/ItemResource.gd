@tool
extends TTResource
class_name ItemResource

enum Category { WEAPON, ARMOR, PACK, TOOL, TRINKET, CONSUMABLE, MISC }

enum WeaponType { SIMPLE_MELEE, SIMPLE_RANGED, MARTIAL_MELEE, MARTIAL_RANGED }
enum ArmorType { LIGHT, MEDIUM, HEAVY, SHIELD }

@export var category: Category = Category.MISC

# Weapon fields
@export var weapon_type: WeaponType
@export var damage_die: String = "1d8"
@export var damage_type: String = "slashing"
@export var weapon_properties: Array[String] = []

# Armor fields
@export var armor_type: ArmorType
@export var armor_class: int = 0
@export var armor_strength_req: int = 0
@export var stealth_disadvantage: bool = false

# General fields
@export var cost_gp: int = 0
@export var weight_lb: float = 0.0
@export var modifiers: Array[StatModifier] = []
@export var requires_attunement: bool = false
@export var is_container: bool = false
@export var default_contents: Array[String] = []
