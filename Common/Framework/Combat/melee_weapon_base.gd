extends WeaponBase
class_name MeleeWeaponBase

@export_group("Melee weapon hitbox")
@export var hitbox_origin: Node2D
@export var hitbox: Area2D = null

var _hitbox_direction: Vector2 = Vector2.ZERO


func _ready() -> void:
    super._ready()
    hitbox_origin.visible = false


func _on_activation() -> void:
    super._on_activation()
    hitbox_origin.visible = true
    if hitbox != null:
        for body in hitbox.get_overlapping_bodies():
            if body == instigator:
                continue
            if HealthComponent.FIELD_NAME in body:
                var health_component: HealthComponent = body[HealthComponent.FIELD_NAME]
                health_component.damage(damage, element)


func _on_cooldown_passed() -> void:
    super._on_cooldown_passed()
    hitbox_origin.visible = false


func _process(_delta: float) -> void:
    super._process(_delta)
    if hitbox != null and instigator != null:
        _hitbox_direction.x = instigator.get_latent_control_direction().x
        hitbox_origin.scale.x = _hitbox_direction.x
        