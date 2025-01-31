extends CharacterWithHealth

class_name PlayerCharacter

@onready var wall_jump_sensor: WallJumpSensor = %WallJumpSensor

@onready var default_collision: CollisionShape2D = %DefaultCollision
@onready var blob_collision: CollisionShape2D = %BlobCollision
@onready var blob_raycast: RayCast2D = %BlobRaycast
var _is_blob: bool = false
var _low_ceiling: bool = false
signal LowCeilingChanged

var _JUMP_FX_POSITION: Vector2 = Vector2(0, 16)
var latent_control_direction_locked: bool = false
var player_state: PlayerState

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
	latent_control_direction_locked = false
	if current_ability != null:
		current_ability.deactivate()    

func _ready() -> void:
	super._ready()
	toggle_blob(false)
	
	player_state = FlowControllerAutoload.player_state
	if player_state == null:
		player_state = PlayerState.new()
		player_state.reset()

	if ability_inventory != null:
		ability_inventory.SwitchAllowChanged.connect(_on_switch_allow_changed)
		ability_inventory.set_combination(player_state.get_last_combination())
		ability_inventory.CombinationSwitched.connect(_on_switch_combination)
		_on_switch_combination()

	FlowControllerAutoload.set_player_character(self)
	health_component.OnDeath.connect(_on_death)
	JumpStarted.connect(_on_jump_started)
	
#	await get_tree().create_timer(2.3).timeout
#	var l = %AudioListener2D as AudioListener2D
#	l.make_current()
	
	
func _on_switch_combination():
	health_component.set_vulnerability_by_rps_rule(ability_inventory.get_current_element())
	player_state.set_last_combination(ability_inventory.get_combination())
	FlowControllerAutoload.add_fx_to_level(FX_Helper.FX_TYPE.SWITCH_COMBINATION, global_position)

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
	
	
func _on_jump_started() -> void:
	FlowControllerAutoload.add_fx_to_level(FX_Helper.FX_TYPE.JUMP, _JUMP_FX_POSITION, Vector2.ONE, 0.0, self)

	
func set_latent_control_direction(in_direction: Vector2) -> void:
	if latent_control_direction_locked:
		return
	if in_direction.x != 0:
		_control_direction_latent.x = in_direction.x
	_control_direction_latent.y = in_direction.y


func update_camera_bounds(left: int, top: int, right: int, bottom: int):
	%Camera2D.limit_left = left
	%Camera2D.limit_top = top
	%Camera2D.limit_right = right
	%Camera2D.limit_bottom = bottom
