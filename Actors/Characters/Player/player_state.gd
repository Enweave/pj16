extends RefCounted

class_name PlayerState

var _last_combination: AbilityInventory.ElementCombinations

func reset():
    _last_combination = AbilityInventory.ElementCombinations.EARTH
    
func get_last_combination() -> AbilityInventory.ElementCombinations:
    return _last_combination
    
func set_last_combination(in_combination: AbilityInventory.ElementCombinations) -> void:
    _last_combination = in_combination