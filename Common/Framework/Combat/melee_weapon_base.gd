extends WeaponBase

class_name MeleeWeaponBase

@export_group("Melee weapon")
@export var hitbox: Area2D = null
@export var animation_player: AnimationPlayer = null

var _hitbox_direction: Vector2 = Vector2.ZERO

func _ready() -> void:
    super._ready()
    

func _process(_delta: float) -> void:
    if hitbox != null and instigator != null:
        _hitbox_direction.x = instigator.get_latent_control_direction().x
        hitbox.rotation = _hitbox_direction.angle()
        