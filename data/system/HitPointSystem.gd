@tool
extends Resource
class_name HitPointSystem

static func get_max_hp_at_level_1(class_resource: ClassResource, con_modifier: int) -> int:
    return class_resource.hit_points_at_1st_level + con_modifier

static func get_average_hp_per_level(class_resource: ClassResource, con_modifier: int) -> int:
    var die = int(class_resource.hit_die.substr(1))  # "d10" → 10
    return floor(die / 2.0) + 1 + con_modifier
