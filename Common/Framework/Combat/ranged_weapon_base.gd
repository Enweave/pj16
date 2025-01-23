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
		var new_control_direction: Vector2 = Vector2.RIGHT
		if instigator != null:
			if instigator is CharacterBase:
				var character: CharacterBase = instigator as CharacterBase
				new_control_direction.x = character.get_latent_control_direction().x
				new_control_direction.y = character.get_latent_control_direction().y
		projectile.aim_and_fire(instigator, new_control_direction, Vector2.ZERO, null)
		
