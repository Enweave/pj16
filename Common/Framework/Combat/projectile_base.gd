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
	if movement_mode == MovementMode.BALLISTIC and _weapon.get_target_object() != null:
		var suggested_velovity: Vector2 = calculate_launch_velocity(global_position, _weapon.get_target_object().global_position, _gravity * gravity_multiplier)
		if suggested_velovity != Vector2.ZERO:
			print("Suggested velocity: ", suggested_velovity)
			_velocity = suggested_velovity
		else:
			print("No solution found")
			_velocity = _vector_from_unit_vector_and_length(_control_direction, speed)
		return
	if movement_mode == MovementMode.BALLISTIC or movement_mode == MovementMode.LINEAR:
		_velocity = _vector_from_unit_vector_and_length(_control_direction, speed)
		return



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
				if _weapon != null:
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


func calculate_launch_velocity(start_pos: Vector2, target_pos: Vector2, gravity: float) -> Vector2:
	"""Calculates the initial velocity needed to launch a body from start_pos to target_pos,
    given a gravitational acceleration.

    Args:
        start_pos: The starting position (Vector2).
        target_pos: The target position (Vector2).
        gravity: The gravitational acceleration (float).  Assumed to be negative downwards.

    Returns:
        A Vector2 representing the initial velocity, or Vector2.Zero if no solution exists (e.g., target is unreachable).
    """
	
	var distance: Vector2 = target_pos - start_pos
	var distance_x: float = distance.x
	var distance_y: float = distance.y
	
	if distance_x == 0:
		return Vector2.ZERO
	
	var time: float = sqrt(abs(2 * distance_y / gravity))
	
	var velocity_x: float = distance_x / time
	var velocity_y: float = gravity * time
	
	return Vector2(velocity_x, -velocity_y)
