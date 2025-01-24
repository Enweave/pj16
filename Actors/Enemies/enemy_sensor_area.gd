extends Area2D

class_name EnemySensorArea

@export var vision_radius: float = 300

func _ready() -> void:
    # add collision shape 2d with circle shape
    var collision_shape: CollisionShape2D = CollisionShape2D.new()
    add_child(collision_shape)
    
    var circle_shape: CircleShape2D = CircleShape2D.new()
    circle_shape.radius = vision_radius
    collision_shape.shape = circle_shape