extends Area2D

class_name ProjectileArea

@export var projectile_radius: float = 8
var projectile: ProjectileBase = null

func _ready() -> void:
    if get_parent() != null:
        projectile = get_parent() as ProjectileBase
        # add circle collision shape with projectile_radius
        var collision_shape: CollisionShape2D = CollisionShape2D.new()
        var circle_shape: CircleShape2D = CircleShape2D.new()
        circle_shape.radius = projectile_radius
        collision_shape.shape = circle_shape
        await call_deferred('add_child', collision_shape)
        body_entered.connect(_on_body_entered)
        
func _on_body_entered(body: Node) -> void:
    if !projectile._alive:
        return
    if !HealthComponent.FIELD_NAME in body:
        return
    if body != projectile._instigator:
        var health_component: HealthComponent = body[HealthComponent.FIELD_NAME]
        var damaged: bool = health_component.damage(projectile._weapon.damage, projectile._weapon.element)
        if damaged:
            FlowControllerAutoload.add_fx_to_level(FX_Helper.FX_TYPE.DEFAULT_IMPACT, body.global_position)
            
        if !projectile.pierce:
            projectile.kill_projectile()