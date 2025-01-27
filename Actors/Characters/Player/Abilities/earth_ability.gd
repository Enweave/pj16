extends RangedWeaponBase

func set_target(in_direction: Vector2 = Vector2.ZERO, in_position: Vector2 = Vector2.ZERO, in_object: Node2D = null) -> void:
    _target_direction = in_direction
    _target_position = in_position


func _ready() -> void:
    super._ready()
    _animation_string_name = "earth_throw"


func _on_activation() -> void:
    super._on_activation()
    set_target_object(self)


func _update_status_label(in_text: String = "") -> void:
    pass