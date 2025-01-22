extends Node
class_name FeatureBase

var _cooldown_time: float  = 0.3
var _wind_up_time: float   = 0.1
var _cost: float           = 0
var _wind_up_timer: Timer
var _cooldown_timer: Timer
var _initialized: bool     = false
var _auto_reactivate: bool = false
var _active: bool          = false

signal Windup
signal Activation
signal CooldownPassed


func _ready():
    pass


func activate() -> bool:
    if _active:
        return false
    _active = true
    _activate()
    return true


func deactivate() -> void:
    _active = false


func reset() -> void:
    _active = false
    _wind_up_timer.stop()
    _cooldown_timer.stop()


func initialize(in_wind_up_time: float, in_cooldown_time: float, in_cost: float, in_auto_reactivate: bool) -> void:
    if _initialized:
        return
    _initialized = true
    _wind_up_timer = Timer.new()
    await call_deferred("add_child", _wind_up_timer)
    _wind_up_timer.wait_time = in_wind_up_time
    _wind_up_timer.one_shot = true
    _wind_up_timer.timeout.connect(_on_wind_up_timer_timeout)

    _cooldown_timer = Timer.new()
    await call_deferred("add_child", _cooldown_timer)
    _cooldown_timer.wait_time = in_cooldown_time
    _cooldown_timer.one_shot = true
    _cooldown_timer.timeout.connect(_on_cooldown_timer_timeout)

    _cost = in_cost
    _auto_reactivate = in_auto_reactivate


func update_params(in_wind_up_time: float, in_cooldown_time: float, in_cost: float, in_auto_reactivate: bool) -> void:
    _wind_up_time = in_wind_up_time
    _cooldown_time = in_cooldown_time
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

    if _auto_reactivate:
        _activate()
    else:
        _active = false