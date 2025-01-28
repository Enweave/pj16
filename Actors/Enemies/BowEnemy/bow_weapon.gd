extends RangedWeaponBase

func _update_sprite_orientation() -> void:
	if weapon_sprite_origin != null:
		weapon_sprite_origin.rotation = get_target_direction().angle()

		
	
