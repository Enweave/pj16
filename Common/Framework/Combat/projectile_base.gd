extends Node2D
class_name ProjectileBase

enum MovementMode {
    LINEAR,
    BALLISTIC,
    HOMING
}
@export var movement_mode: MovementMode = MovementMode.LINEAR

@export_range(0., 1.) var gravity_multiplier: float = 1
@export var orient_to_motion: bool = true
@export var lifetime: float = 0.5
@export var speed: float = 900
@export var pierce: bool = false

var _control_direction: Vector2 = Vector2.ZERO
var _lifetime_timer: Timer
var _alive: bool             = false
var _gravity: float          = ProjectSettings.get_setting("physics/2d/default_gravity") as float
var _instigator: Node2D      = null
var _weapon: WeaponBase      = null
var _velocity: Vector2        = Vector2.ZERO


func _vector_from_unit_vector_and_length(in_vector: Vector2, in_length: float) -> Vector2:
    var new_vector: Vector2 = Vector2.ZERO
    new_vector.x = in_length * cos(in_vector.angle())
    new_vector.y = in_length * sin(in_vector.angle())
    return new_vector

func launch(in_instigator: Node2D, in_weapon: WeaponBase) -> void:
    _weapon = in_weapon
    _control_direction = in_weapon.get_target_direction()
    _instigator = in_instigator
    _lifetime_timer = Timer.new()
    _lifetime_timer.wait_time = lifetime
    _lifetime_timer.one_shot = true
    _lifetime_timer.timeout.connect(_on_lifetime_timer_timeout)
    _lifetime_timer.autostart = true
    await (call_deferred('add_child', _lifetime_timer))
    _alive = true
    if movement_mode == MovementMode.BALLISTIC or movement_mode == MovementMode.LINEAR:
        print("Projectile launched", (_control_direction * speed).length())
        _velocity = _vector_from_unit_vector_and_length(_control_direction, speed)


func _update_orientation(in_direction: Vector2 = Vector2.ZERO) -> void:
    if orient_to_motion:
        rotation = in_direction.angle()

func _process(delta: float) -> void:
    if _alive:
        match movement_mode:
            MovementMode.LINEAR:
                position += _velocity * delta
                _update_orientation(_velocity)
            MovementMode.BALLISTIC:
                _velocity.y += clamp(gravity_multiplier * _gravity * delta, -Constants.TERMINAL_VELOCITY, Constants.TERMINAL_VELOCITY)
                position += _velocity * delta
                _update_orientation(_velocity)
            MovementMode.HOMING:
                if _weapon._target_object != null:
                    var direction: Vector2 = _weapon.get_target_object().global_position - position
                    direction = direction.normalized()
                    position += direction * speed * delta
                    _update_orientation(direction)


func kill_projectile() -> void:
    if !_alive:
        return
    _alive = false
    call_deferred("queue_free")  
            
func _on_lifetime_timer_timeout() -> void:
    kill_projectile()