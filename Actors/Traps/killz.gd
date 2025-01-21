extends Node2D

func _on_area_2d_body_entered( body: Node ) -> void:
	if body is PlayerCharacter:
		FlowControllerAutoload.game_over()
		return
	if HealthComponent.FIELD_NAME in body:
		var health_component: HealthComponent = body[HealthComponent.FIELD_NAME]
		health_component.instakill()
	else:
		body.queue_free()

