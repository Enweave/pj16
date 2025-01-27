extends CharacterBase

class_name CharacterWithHealth

@export_group("Health")
@export var health_component: HealthComponent

func _ready():
    super._ready()
    if health_component == null:
        health_component = HealthComponent.new()
        call_deferred("add_child", health_component)