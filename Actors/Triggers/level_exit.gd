extends Area2D

func _on_body_entered(body: Node) -> void:
    if body is PlayerCharacter:
        FlowControllerAutoload.load_next_level()