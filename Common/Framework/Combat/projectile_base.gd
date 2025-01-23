extends Node2D
class_name ProjectileBase

enum MovementMode {
    LINEAR,
    BALLISTIC,
    HOMING_STATIC,
    HOMING_DYNAMIC
}
@export var movement_mode: MovementMode = MovementMode.LINEAR

@export_range(0., 1.) var gravity_multiplier: float = 1
@export var orient_to_motion: bool = true
@export var lifetime: float = 0.5
@export var speed: float = 900

var _control_direction: Vector2 = Vector2.ZERO
var damage: float               = 1
var target_location: Vector2 = Vector2.ZERO
var target_object: Node2D    = null
var _lifetime_timer: Timer
var _alive: bool             = false
var _gravity: float          = ProjectSettings.get_setting("physics/2d/default_gravity") as float
var _instigator: Node2D      = null
var _velocity: Vector2        = Vector2.ZERO

func aim_and_fire(in_instigator: Node2D = null, in_direction: Vector2 = Vector2.ZERO, in_target_location: Vector2 = Vector2.ZERO, in_target_object: Node2D = null) -> void:
    _control_direction.x = clamp(in_direction.x, -1, 1)
    _control_direction.y = clamp(in_direction.y, -1, 1)
    _instigator = in_instigator
    target_location = in_target_location
    target_object = in_target_object
    _lifetime_timer = Timer.new()
    _lifetime_timer.wait_time = lifetime
    _lifetime_timer.one_shot = true
    _lifetime_timer.timeout.connect(_on_lifetime_timer_timeout)
    _lifetime_timer.autostart = true
    await (call_deferred('add_child', _lifetime_timer))
    _alive = true


func _update_orientation(in_direction: Vector2 = Vector2.ZERO) -> void:
    if orient_to_motion:
        rotation = in_direction.angle()

func _process(delta: float) -> void:
    if _alive:
        _velocity = _control_direction * speed
        match movement_mode:
            MovementMode.LINEAR:
                position += _velocity * delta
                _update_orientation(_velocity)
            MovementMode.BALLISTIC:
                _velocity.y += clamp(gravity_multiplier * _gravity * delta, -Constants.TERMINAL_VELOCITY, Constants.TERMINAL_VELOCITY)
                position += _velocity * delta
                _update_orientation(_velocity)
            MovementMode.HOMING_STATIC:
                if target_location != Vector2.ZERO:
                    var direction: Vector2 = target_location - position
                    direction = direction.normalized()
                    position += direction * speed * delta
                    _update_orientation(direction)
            MovementMode.HOMING_DYNAMIC:
                if target_object != null:
                    var direction: Vector2 = target_object.position - position
                    direction = direction.normalized()
                    position += direction * speed * delta
                    _update_orientation(direction)


func _on_lifetime_timer_timeout() -> void:
    _alive = false
    call_deferred("queue_free")