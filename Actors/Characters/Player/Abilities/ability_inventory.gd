extends Node2D
class_name AbilityInventory

@export var fire_ability: FeatureBase = null
@export var water_ability: FeatureBase = null
@export var earth_ability: FeatureBase = null
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
signal SwitchAllowChanged(arg: bool)
var _switching_allowed: bool = true

var _unlocked_combinations: Array = [
ElementCombinations.EARTH,
ElementCombinations.FIRE,
ElementCombinations.WATER,
ElementCombinations.FIRE_WATER,
ElementCombinations.FIRE_EARTH,
ElementCombinations.WATER_EARTH
]

var _current_combination: ElementCombinations = ElementCombinations.WATER
var _current_ability: FeatureBase = null
var _current_element: Constants.Elements = Constants.Elements.Earth
var _previous_element: Constants.Elements = Constants.Elements.Earth
const SINGLE_ELEMENT: bool = true


func get_current_ability() -> FeatureBase:
    return _current_ability

func set_switching_allowed(in_allowed: bool) -> void:
    SwitchAllowChanged.emit(in_allowed)
    _switching_allowed = in_allowed

    
func get_current_element() -> Constants.Elements:
    return _current_element

func unlock_combination(in_combination: ElementCombinations) -> void:
    if _unlocked_combinations.find(in_combination) == -1:
        _unlocked_combinations.append(in_combination)
        CombinationUnlocked.emit()


func _switch_ability(in_combination: ElementCombinations):
    match in_combination:
        ElementCombinations.FIRE:
            _current_ability = fire_ability
            _current_element = Constants.Elements.Fire
        ElementCombinations.WATER:
            _current_ability = water_ability
            _current_element = Constants.Elements.Water
        ElementCombinations.EARTH:
            _current_ability = earth_ability
            _current_element = Constants.Elements.Earth

        # TODO: Implement combination abilities
        ElementCombinations.FIRE_WATER:
            _current_ability = water_ability
            _current_element = Constants.Elements.Fire
        ElementCombinations.FIRE_EARTH:
            _current_ability = earth_ability
            _current_element = Constants.Elements.Fire
        ElementCombinations.WATER_EARTH:
            _current_ability = earth_ability
            _current_element = Constants.Elements.Water
    CombinationSwitched.emit()


func switch(in_element: Constants.Elements) -> bool:
    if not _switching_allowed:
        return false

    if SINGLE_ELEMENT:
        _previous_element = in_element
        match in_element:
            Constants.Elements.Fire:
                _current_combination = ElementCombinations.FIRE
            Constants.Elements.Water:
                _current_combination = ElementCombinations.WATER
            Constants.Elements.Earth:
                _current_combination = ElementCombinations.EARTH
        _switch_ability(_current_combination)
        return true
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

        _switch_ability(_current_combination)
        return true
    return false


func set_combination(in_combination: ElementCombinations) -> void:
    _current_combination = in_combination
    _switch_ability(_current_combination)
    
func get_combination() -> ElementCombinations:
    return _current_combination