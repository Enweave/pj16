extends CharacterWithHealth

class_name PlayerCharacter

@onready var wall_jump_sensor: WallJumpSensor = %WallJumpSensor

func _ready() -> void:
    super._ready()
    FlowControllerAutoload.set_player_character(self)
    
    
func _is_colliding_wall() -> bool:
    if is_on_floor():
        return false
    var wall_direction: int = wall_jump_sensor.get_wall_direction()
    set_wall_direction(wall_direction)
    return wall_direction != 0