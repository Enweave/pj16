extends CharacterBase

class_name CharacterWithHealth

var health_component: HealthComponent

@export_group("Health")
@export var max_health: float = 10
@export var element: Constants.Elements = Constants.Elements.None

func _ready():
    super._ready()
    health_component = HealthComponent.new(max_health, element)