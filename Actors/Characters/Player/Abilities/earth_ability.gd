extends RangedWeaponBase

func set_target(in_direction: Vector2 = Vector2.ZERO, in_position: Vector2 = Vector2.ZERO, _in_object: Node2D = null) -> void:
    _target_direction = in_direction
    _target_position = in_position
    

func _ready() -> void:
    super._ready()
    _animation_string_name = "earth_throw"


func _on_activation() -> void:
    super._on_activation()
    _target_object = null


func _update_status_label(_in_text: String = "") -> void:
    pass