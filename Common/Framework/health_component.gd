extends RefCounted

class_name HealthComponent

const FIELD_NAME: String = "health_component"
signal OnDamage(amount: float)
signal OnHeal(amount: float)
signal OnDeath
var _max_health: float    = 10.
var current_health: float
var is_invulnerable: bool = false
var is_dead: bool         = false
var element: Constants.Elements = Constants.Elements.None

func _init(in_max_health: float, in_element: Constants.Elements = Constants.Elements.None) -> void:
    _max_health = in_max_health
    current_health = _max_health
    element = in_element


func _element_can_damage(in_element: Constants.Elements = Constants.Elements.None) -> bool:
    # If the element is 0, it means that the element can damage anything
    # otherwise - rock paper scissors logic:
    # Fire -> Earth -> Water -> Fire
    
    if in_element == Constants.Elements.None:
        return true
        
    match in_element:
        Constants.Elements.Fire:
            return element == Constants.Elements.Earth
        Constants.Elements.Water:
            return element == Constants.Elements.Fire
        Constants.Elements.Earth:
            return element == Constants.Elements.Water
        null:
            return false 
    
    return true


func update_max_health(value: float) -> void:
    _max_health = value
    current_health = min(current_health, _max_health)


func damage(amount: float, in_element: Constants.Elements = Constants.Elements.None) -> bool:
    if is_invulnerable or is_dead:
        return false
    
    if not _element_can_damage(in_element):
        return false

    current_health -= amount #amount

    if current_health <= 0:
        is_dead = true
        OnDeath.emit()
    OnDamage.emit(amount)
    return true

func instakill() -> void:
    is_dead = true
    current_health = 0
    OnDeath.emit()


func is_full() -> bool:
    return current_health == _max_health


func heal(amount: float) -> void:
    current_health = min(current_health + amount, _max_health)
    OnHeal.emit(amount)
	
