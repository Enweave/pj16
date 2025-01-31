extends MeleeWeaponBase

func _update_status_label(_in_text: String = "") -> void:
    pass


func _ready() -> void:
    super._ready()
    _animation_string_name = "fire_action"
    
    
func _on_activation() -> void:
    super._on_activation()
    if owner is PlayerCharacter:
        var p: PlayerCharacter = owner as PlayerCharacter
        p.latent_control_direction_locked = true