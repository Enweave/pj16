extends Node

class_name AbilityInventory

enum ElementCombinations {
	FIRE,
	WATER,
	EARTH,
	FIRE_WATER,
	FIRE_EARTH,
	WATER_EARTH,
}

signal CombinationUnlocked
signal CombinationSwitched

var _switching_allowed: bool = true
var _unlocked_combinations: Array = [ElementCombinations.EARTH]
var _current_combination: ElementCombinations = ElementCombinations.EARTH
var _previous_element: Constants.Elements = Constants.Elements.Earth

func unlock_combination(in_combination: ElementCombinations) -> void:
	if _unlocked_combinations.find(in_combination) == -1:
		_unlocked_combinations.append(in_combination)
		CombinationUnlocked.emit()
		
func switch(in_element: Constants.Elements) -> bool:
	if not _switching_allowed:
		return false
	var new_combination: ElementCombinations = _current_combination
	
	if _previous_element == in_element:
		match in_element:
			Constants.Elements.Fire:
				new_combination = ElementCombinations.FIRE
			Constants.Elements.Water:
				new_combination = ElementCombinations.WATER
			Constants.Elements.Earth:
				new_combination = ElementCombinations.EARTH

	else:
		match _previous_element:
			Constants.Elements.Fire:
				match in_element:
					Constants.Elements.Water:
						new_combination = ElementCombinations.FIRE_WATER
					Constants.Elements.Earth:
						new_combination = ElementCombinations.FIRE_EARTH
			Constants.Elements.Water:
				match in_element:
					Constants.Elements.Fire:
						new_combination = ElementCombinations.FIRE_WATER
					Constants.Elements.Earth:
						new_combination = ElementCombinations.WATER_EARTH
			Constants.Elements.Earth:
				match in_element:
					Constants.Elements.Fire:
						new_combination = ElementCombinations.FIRE_EARTH
					Constants.Elements.Water:
						new_combination = ElementCombinations.WATER_EARTH
				
	if _unlocked_combinations.find(new_combination) != -1:
		_previous_element = in_element
		_current_combination = new_combination
		
		CombinationSwitched.emit()
		return true
	return false