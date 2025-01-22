extends CharacterWithHealth

class_name PlayerCharacter

@onready var wall_jump_sensor: WallJumpSensor = %WallJumpSensor
var current_feature: FeatureBase = null

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
    current_feature = FeatureBase.new()
    current_feature.initialize(0.1, 0.3, 0, true)
    call_deferred("add_child", current_feature)
    
func _on_death() -> void:
    FlowControllerAutoload.game_over()
    
func _is_colliding_wall() -> bool:
    if is_on_floor():
        return false
    var wall_direction: int = wall_jump_sensor.get_wall_direction()
    set_wall_direction(wall_direction)
    return wall_direction != 0