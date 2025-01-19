extends Node2D

class_name WallJumpSensor

@onready var sensor_left: Area2D = $WallSensorLeft
@onready var sensor_right: Area2D = $WallSensorRight

func get_wall_direction() -> int:
    if sensor_left.has_overlapping_bodies():
        return -1
    elif sensor_right.has_overlapping_bodies():
        return 1
    return 0