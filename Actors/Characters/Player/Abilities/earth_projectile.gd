extends ProjectileBase


func launch(in_instigator: Node2D, in_weapon: WeaponBase) -> void:
	lifetime = in_weapon._cooldown_time
	super.launch(in_instigator, in_weapon)
	var return_timer: Timer = %ReturnTimer
	return_timer.wait_time = lifetime/2.
	return_timer.timeout.connect(_on_return_timer_timeout)
	
func _on_return_timer_timeout() -> void:
	_weapon.set_target_object(_weapon)
	movement_mode = MovementMode.HOMING
