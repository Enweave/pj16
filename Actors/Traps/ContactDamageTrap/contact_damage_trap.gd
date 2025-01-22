extends Node2D

@export var element: Constants.Elements = Constants.Elements.None
@export var damage: float = 1

func _on_area_2d_body_entered(body: Node) -> void:
    if HealthComponent.FIELD_NAME in body:
        var health_component: HealthComponent = body[HealthComponent.FIELD_NAME]
        health_component.damage(damage, element)