extends CharacterWithHealth

class_name PlayerCharacter

@onready var wall_jump_sensor: WallJumpSensor = %WallJumpSensor
@export var current_feature: FeatureBase = null


func activate_current_feature() -> bool:
    if current_feature != null:
        return current_feature.activate()
    return false

func deactivate_current_feature() -> void:
    if current_feature != null:
        current_feature.deactivate()    

func _ready() -> void:
    super._ready()
    FlowControllerAutoload.set_player_character(self)
    health_component.OnDeath.connect(_on_death)
    
func _on_death() -> void:
    FlowControllerAutoload.game_over()
    
func _is_colliding_wall() -> bool:
    if is_on_floor():
        return false
    var wall_direction: int = wall_jump_sensor.get_wall_direction()
    set_wall_direction(wall_direction)
    return wall_direction != 0