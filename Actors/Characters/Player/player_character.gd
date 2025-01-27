extends CharacterWithHealth

class_name PlayerCharacter

@onready var wall_jump_sensor: WallJumpSensor = %WallJumpSensor

@onready var default_collision: CollisionShape2D = %DefaultCollision
@onready var blob_collision: CollisionShape2D = %BlobCollision
@onready var blob_raycast: RayCast2D = %BlobRaycast
var _is_blob: bool = false
var _low_ceiling: bool = false
signal LowCeilingChanged

func toggle_blob(in_toggle: bool) -> void:
    _is_blob = in_toggle
    blob_collision.disabled = !in_toggle
    default_collision.disabled = in_toggle


@onready var ability_inventory: AbilityInventory = %AbilityInventory
var using_ability: bool = false

func activate_current_feature() -> bool:
    if ability_inventory != null:
        var current_ability: FeatureBase = ability_inventory.get_current_ability()
        if current_ability == null:
            return false
        current_ability.set_target(get_latent_control_direction())
        return current_ability.activate()
    return false

func deactivate_current_feature() -> void:
    var current_ability: FeatureBase = ability_inventory.get_current_ability()
    if current_ability != null:
        current_ability.deactivate()    

func _ready() -> void:
    super._ready()
    toggle_blob(false)
    
    if ability_inventory != null:
        ability_inventory.SwitchAllowChanged.connect(_on_switch_allow_changed)
        ability_inventory.set_combination(AbilityInventory.ElementCombinations.FIRE)
        ability_inventory.CombinationSwitched.connect(_on_switch_combination)
        _on_switch_combination()

    FlowControllerAutoload.set_player_character(self)
    health_component.OnDeath.connect(_on_death)
    
    
func _on_switch_combination():
    health_component.element = ability_inventory.get_current_element()

func _on_switch_allow_changed(in_allowed: bool):
    using_ability = !in_allowed
    
func switch_combination(in_element: Constants.Elements) -> void:
    if ability_inventory != null:
        ability_inventory.switch(in_element)

        
func _on_death() -> void:
    FlowControllerAutoload.game_over()
    
func _update_low_ceiling() -> void:
    if _is_blob:
        if _low_ceiling != blob_raycast.is_colliding():
            _low_ceiling = !_low_ceiling
            LowCeilingChanged.emit()
        return
    _low_ceiling = false

func _process(delta: float) -> void:
    super._process(delta)
    _update_low_ceiling()

func _is_colliding_wall() -> bool:
    if is_on_floor():
        return false
    var wall_direction: int = wall_jump_sensor.get_wall_direction()
    set_wall_direction(wall_direction)
    return wall_direction != 0