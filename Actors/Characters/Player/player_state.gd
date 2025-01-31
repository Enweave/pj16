extends RefCounted

class_name PlayerState

var _last_combination: AbilityInventory.ElementCombinations
var _score: int

func reset():
    _last_combination = AbilityInventory.ElementCombinations.EARTH
    _score = 0
    
func get_score() -> int:
    return _score
    
func set_score(in_score: int) -> void:
    _score = in_score

func get_last_combination() -> AbilityInventory.ElementCombinations:
    return _last_combination
    
func set_last_combination(in_combination: AbilityInventory.ElementCombinations) -> void:
    _last_combination = in_combination