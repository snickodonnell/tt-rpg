@tool
extends Resource
class_name AbilitySystem

# 27-point buy cost table (standard 2014 RAW)
static func get_point_buy_cost(score: int) -> int:
    match score:
        8: return 0
        9: return 1
        10: return 2
        11: return 3
        12: return 4
        13: return 5
        14: return 7
        15: return 9
        _: return 999  # invalid

static func get_modifier(score: int) -> int:
    return (score - 10) / 2

static func validate_point_buy(base_scores: Dictionary) -> bool:
    var total = 0
    for score in base_scores.values():
        total += get_point_buy_cost(score)
    return total <= 27

static func get_proficiency_bonus(level: int) -> int:
    return 2 + floor((level - 1) / 4)
