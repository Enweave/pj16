extends WeaponBase

class_name RangedWeaponBase

@export_group("Ranged weapon")
@export var projectile_scene: PackedScene = null

func _on_activation() -> void:
	super._on_activation()
	if projectile_scene != null:
		var projectile: ProjectileBase = projectile_scene.instantiate()
	
		await FlowControllerAutoload.add_child_to_level(projectile)
		
		projectile.position = self.global_position
		projectile.launch(instigator, self)
		
