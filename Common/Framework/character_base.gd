extends CharacterBody2D
class_name CharacterBase

var _gravity: float = ProjectSettings.get_setting("physics/2d/default_gravity") as float

@export_group("Movement")
@export var SPEED: float = 200

@export_range(0., 1.) var AIR_CONTROL: float = 1

@export_range(0., 1.) var AIR_FRICTION: float = 0.9
@export var ACCELERATION: float = 30

@export_range(0., 1.) var GRAVITY_SCALE: float = 1

@export_range(0., Constants.TERMINAL_VELOCITY) var TERMINAL_VELOCITY_HORIZONTAL: float = 500

@export_range(0., Constants.TERMINAL_VELOCITY) var TERMINAL_VELOCITY_VERTICAL: float = 400

var _use_control_direction: bool = true

@onready var _deceleration: float = SPEED/8

var _control_direction: Vector2 = Vector2.ZERO
var _control_direction_inertial: Vector2 = Vector2.ZERO
var _control_direction_latent: Vector2 = Vector2.RIGHT
var _control_direction_scale: float = 1

@onready var _gravity_scale: float = GRAVITY_SCALE

@export_group("Jump")
@export var JUMP_FORCE: float = 300.
@export var JUMP_NUM_MAX: int = 1
@export var JUMP_INPUT_BUFFER_TIME: float = 0.05
@export var JUMP_COYOTE_TIME: float = 0.2
@export_group("Wall Jump")
@export var WALL_JUMP_ENABLED: bool = false
@export var WALL_JUMP_FORCE_Y: float = 275.
@export var WALL_JUMP_FORCE_X: float = 338.

@onready var _jump_num_max: int = JUMP_NUM_MAX

var _jump_triggered: bool = false
var _coyote_active: bool = false
var _wall_coyote_active: bool = false

@onready var _jumps_left: int = JUMP_NUM_MAX
@onready var _wall_jump_enabled: bool = WALL_JUMP_ENABLED

var _wall_direction: float = 0

@export_group("Misc")
@export var PUSH_RIGID_BODIES: bool = false
@export var PUSH_RIGID_BODIES_FORCE: float = 2
signal jump_started
signal landed
var _jump_buffer_timer: Timer
var _coyote_timer: Timer
var _wall_coyote_timer: Timer


# override this in character
func _is_colliding_wall() -> bool:
    return false


func _ready():
    _coyote_timer = Timer.new()
    _coyote_timer.set_one_shot(true)
    _coyote_timer.set_wait_time(JUMP_COYOTE_TIME)
    _coyote_timer.timeout.connect(_on_coyote_timeout)

    _wall_coyote_timer = Timer.new()
    _wall_coyote_timer.set_one_shot(true)
    _wall_coyote_timer.set_wait_time(JUMP_COYOTE_TIME)
    _wall_coyote_timer.timeout.connect(_on_wall_coyote_timeout)

    _jump_buffer_timer = Timer.new()
    _jump_buffer_timer.set_one_shot(true)
    _jump_buffer_timer.set_wait_time(JUMP_INPUT_BUFFER_TIME)
    _jump_buffer_timer.timeout.connect(_on_buffer_jump_timeout)

    add_child(_coyote_timer)
    add_child(_wall_coyote_timer)
    add_child(_jump_buffer_timer)


func activate_current_feature() -> bool:
    return false


func deactivate_current_feature() -> void:
    pass


func _apply_jump_force() -> void:
    if WALL_JUMP_ENABLED:
        if _wall_coyote_active and _wall_direction != 0:
            _control_direction_inertial.x = -_wall_direction
            velocity = Vector2(-_wall_direction * WALL_JUMP_FORCE_X, -WALL_JUMP_FORCE_Y)
            return

    velocity.y = -JUMP_FORCE
    _jumps_left -= 1


func _try_perform_jump() -> bool:
    if _coyote_active or _jumps_left > 0 or _wall_coyote_active:
        _apply_jump_force()
        _coyote_active = false
        _wall_coyote_active = false
        _jump_triggered = false
        return true
    return false


func _update_jump_conditions(_delta: float) -> void:
    if is_on_floor():
        _jumps_left = _jump_num_max
        _coyote_active = true
        _coyote_timer.set_paused(true)
    else:
        if _coyote_timer.paused:
            _coyote_timer.set_paused(false)
            _coyote_timer.start()

    if _wall_jump_enabled:
        if _is_colliding_wall():
            _wall_coyote_active = true
            _wall_coyote_timer.set_paused(true)
        else:
            if _wall_coyote_timer.paused:
                _wall_coyote_timer.set_paused(false)
                _wall_coyote_timer.start()


func _on_buffer_jump_timeout() -> void:
    if !_jump_triggered:
        return
    _jump_triggered = false
    _try_perform_jump()


func _on_coyote_timeout() -> void:
    if _coyote_active:
        _jumps_left -= 1
        _coyote_active = false


func _on_wall_coyote_timeout() -> void:
    _wall_coyote_active = false


func _process_gravity(delta: float) -> void:
    if is_on_floor():
        _control_direction_scale = 1
    else:
        _control_direction_scale = AIR_CONTROL

    var new_velocity: float = velocity.y + _gravity * _gravity_scale * delta
    velocity.y = clamp(new_velocity, -TERMINAL_VELOCITY_VERTICAL, TERMINAL_VELOCITY_VERTICAL)


func _process_movement(_delta: float) -> void:
    var new_velocity: float = velocity.x

    if _use_control_direction:
        if _control_direction.x == 0:
            new_velocity = move_toward(new_velocity, _control_direction_inertial.x * SPEED * (1. - AIR_FRICTION), _deceleration)
        else:
            new_velocity = move_toward(new_velocity, _control_direction.x * SPEED * _control_direction_scale, ACCELERATION)

    velocity.x = clamp(new_velocity, -TERMINAL_VELOCITY_HORIZONTAL, TERMINAL_VELOCITY_HORIZONTAL)


func _push_rigid_bodies(delta: float) -> void:
    for i in get_slide_collision_count():
        var c: KinematicCollision2D = get_slide_collision(i)
        if c.get_collider() is RigidBody2D:
            var r: RigidBody2D = c.get_collider()
            r.apply_central_impulse(-c.get_normal() * PUSH_RIGID_BODIES_FORCE * delta)


func _physics_process(delta):
    _process_gravity(delta)
    _process_movement(delta)
    move_and_slide()
    _update_jump_conditions(delta)

    if PUSH_RIGID_BODIES:
        _push_rigid_bodies(delta)


func set_latent_control_direction(in_direction: Vector2) -> void:
    if in_direction.x != 0:
        _control_direction_latent.x = in_direction.x
    _control_direction_latent.y = in_direction.y


func trigger_jump() -> void:
    var result: bool = _try_perform_jump()
    if !result:
        if !_jump_triggered:
            _jump_triggered = true
            _jump_buffer_timer.start()


func get_control_direction() -> Vector2:
    return _control_direction    
    
func set_control_direction(in_direction: Vector2) -> void:
    _control_direction.x = clamp(in_direction.x, -1, 1)
    _control_direction.y = clamp(in_direction.y, -1, 1)

    set_latent_control_direction(_control_direction)

    if is_on_floor():
        _control_direction_inertial = Vector2.ZERO
    else:
        if _control_direction.x != 0:
            _control_direction_inertial.x = _control_direction.x
        if _control_direction.y != 0:
            _control_direction_inertial.y = _control_direction.y


func get_latent_control_direction() -> Vector2:
    return _control_direction_latent


func set_wall_direction(in_wall_direction: float) -> void:
    _wall_direction = in_wall_direction


func set_use_control_direction(in_use_control_direction: bool) -> void:
    _use_control_direction = in_use_control_direction


func set_gravity_scale(in_gravity_scale: float) -> void:
    _gravity_scale = in_gravity_scale


func reset_gravity_scale() -> void:
    _gravity_scale = GRAVITY_SCALE


func set_jump_num_max(in_jump_num_max: int) -> void:
    _jump_num_max = in_jump_num_max


func set_wall_jump_enabled(in_wall_jump_enabled: bool) -> void:
    _wall_jump_enabled = in_wall_jump_enabled
