extends CharacterBase

class_name CharacterWithHealth

@export_group("Health")
@export var health_component: HealthComponent

func _ready():
    super._ready()
    if health_component == null:
        health_component = HealthComponent.new()
        call_deferred("add_child", health_component)
    
    health_component.OnDamage.connect(_on_damage_fx)
    
    
func _on_damage_fx(_amount: float, _element: Constants.Elements = Constants.Elements.None) -> void:
    print("Damage FX", _amount, _element)
    FlowControllerAutoload.add_fx_to_level(FX_Helper.FX_TYPE.DEFAULT_IMPACT, global_position)