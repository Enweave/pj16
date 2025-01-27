extends Node2D
class_name FeatureBase

var _cooldown_time: float  = 0.3
var _wind_up_time: float   = 0.1
var _cost: float           = 0
var _wind_up_timer: Timer
var _cooldown_timer: Timer
var _initialized: bool     = false
var _auto_reactivate: bool = false
var _active: bool          = false
var _trigger_down: bool    = false
var _locked: bool          = false
signal Windup
signal Activation
signal CooldownPassed

var _target_direction: Vector2 = Vector2.ZERO
var _target_position: Vector2  = Vector2.ZERO
var _target_object: Node2D     = null


func _ready():
	pass


func set_target(in_direction: Vector2 = Vector2.ZERO, in_position: Vector2 = Vector2.ZERO, in_object: Node2D = null) -> void:
	_target_direction = in_direction
	_target_position = in_position
	_target_object = in_object

func get_target_direction() -> Vector2:
	return _target_direction

func get_target_object() -> Node2D:
	return _target_object


func activate() -> bool:
	if _locked:
		return false
	_trigger_down = true
	if _active:
		return false
	_active = true
	_activate()
	return true

func lock() -> void:
	_locked = true

func unlock(in_emit: bool = true) -> void:
	_locked = false
	if _cooldown_timer.is_stopped():
		if in_emit:
			CooldownPassed.emit()
		_active = false
		_trigger_down = false

func deactivate() -> void:
	_trigger_down = false


func reset() -> void:
	_active = false
	_locked = false
	_wind_up_timer.stop()
	_cooldown_timer.stop()


func initialize(in_wind_up_time: float, in_cooldown_time: float, in_cost: float, in_auto_reactivate: bool) -> void:
	if _initialized:
		return
	_initialized = true
	_wind_up_timer = Timer.new()

	_wind_up_time = in_wind_up_time
	if in_wind_up_time > 0:
		_wind_up_timer.wait_time = in_wind_up_time

	_wind_up_timer.one_shot = true
	_wind_up_timer.timeout.connect(_on_wind_up_timer_timeout)

	_cooldown_timer = Timer.new()

	_cooldown_time = in_cooldown_time
	if in_cooldown_time > 0:
		_cooldown_timer.wait_time = in_cooldown_time

	_cooldown_timer.one_shot = true
	_cooldown_timer.timeout.connect(_on_cooldown_timer_timeout)

	_cost = in_cost
	_auto_reactivate = in_auto_reactivate
	await get_tree().create_timer(in_wind_up_time).timeout

	await call_deferred("add_child", _wind_up_timer)
	await call_deferred("add_child", _cooldown_timer)


func update_params(in_wind_up_time: float, in_cooldown_time: float, in_cost: float, in_auto_reactivate: bool) -> void:
	_wind_up_time = in_wind_up_time
	if in_wind_up_time > 0:
		_wind_up_timer.wait_time = in_wind_up_time
	_cooldown_time = in_cooldown_time
	if in_cooldown_time > 0:
		_cooldown_timer.wait_time = in_cooldown_time

	_cost = in_cost
	_auto_reactivate = in_auto_reactivate

	if _initialized:
		_wind_up_timer.wait_time = in_wind_up_time
		_cooldown_timer.wait_time = in_cooldown_time


func _activate() -> void:
	if !_active:
		return
	if _wind_up_time > 0:
		_wind_up_timer.start()
		Windup.emit()
	else:
		_on_wind_up_timer_timeout()


func _on_wind_up_timer_timeout() -> void:
	Activation.emit()
	if _cooldown_time > 0:
		_cooldown_timer.start()
	else:
		_on_cooldown_timer_timeout()


func _on_cooldown_timer_timeout() -> void:
	CooldownPassed.emit()

	if _locked:
		_active = false
		return

	if _auto_reactivate and _trigger_down:
		_activate()
	else:
		_active = false
		_trigger_down = false
