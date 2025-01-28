extends MeleeWeaponBase

func _update_status_label(_in_text: String = "") -> void:
    pass


func _ready() -> void:
    super._ready()
    _animation_string_name = "fire_action"