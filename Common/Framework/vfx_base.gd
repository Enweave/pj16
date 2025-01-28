extends Node2D

class_name VfxBase

@export var duration: float = 0.5

func _ready() -> void:
    await get_tree().create_timer(duration).timeout
    queue_free()