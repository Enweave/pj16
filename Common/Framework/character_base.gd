extends CharacterBody2D
class_name CharacterBase

var gravity: float = ProjectSettings.get_setting("physics/2d/default_gravity") as float

@export_group("Movement")
@export var SPEED: float = 200
@export var AIR_CONTROL: float = 1
@export var AIR_FRICTION: float = 0.96
@export var ACCELERATION: float = 30
@export var GRAVITY_SCALE: float = 1
@export var TERMINAL_VELOCITY_HORIZONTAL: float = 500
@export var TERMINAL_VELOCITY_VERTICAL: float = 400

var DECELERATION: float               = SPEED/8
var control_direction: Vector2        = Vector2.ZERO
var control_direction_latent: Vector2 = Vector2.ZERO
var control_direction_scale: float    = 1

@export_group("Jump")
@export var JUMP_FORCE: float = 300.
@export var JUMP_NUM_MAX: int = 1
@export var JUMP_INPUT_BUFFER_TIME: float = 0.05
@export var JUMP_COYOTE_TIME: float = 0.2
@export_group("Wall Jump")
@export var WALL_JUMP_ENABLED: bool = true
@export var WALL_JUMP_FORCE_Y: float = 275.
@export var WALL_JUMP_FORCE_X: float = 338.

var jump_triggered: bool     = false
var coyote_active: bool      = false
var wall_coyote_active: bool = false
var jumps_left: int          = JUMP_NUM_MAX
var wall_direction: float    = 0

@export_group("Misc")
@export var PUSH_RIGID_BODIES: bool = false
@export var PUSH_RIGID_BODIES_FORCE: int = 2
signal jump_started
signal landed
var jump_buffer_timer: Timer
var coyote_timer: Timer
var wall_coyote_timer: Timer


func _ready():
    coyote_timer = Timer.new()
    coyote_timer.set_one_shot(true)
    coyote_timer.set_wait_time(JUMP_COYOTE_TIME)
    coyote_timer.timeout.connect(_on_coyote_timeout)

    wall_coyote_timer = Timer.new()
    wall_coyote_timer.set_one_shot(true)
    wall_coyote_timer.set_wait_time(JUMP_COYOTE_TIME)
    wall_coyote_timer.timeout.connect(_on_wall_coyote_timeout)

    jump_buffer_timer = Timer.new()
    jump_buffer_timer.set_one_shot(true)
    jump_buffer_timer.set_wait_time(JUMP_INPUT_BUFFER_TIME)
    jump_buffer_timer.timeout.connect(_on_buffer_jump_timeout)

    add_child(coyote_timer)
    add_child(wall_coyote_timer)
    add_child(jump_buffer_timer)


func set_control_direction(direction: Vector2) -> void:
    control_direction.x = clamp(direction.x, -1, 1)
    control_direction.y = clamp(direction.y, -1, 1)
    if is_on_floor():
        control_direction_latent = Vector2.ZERO
    else:
        if control_direction.x != 0:
            control_direction_latent.x = control_direction.x
        if control_direction.y != 0:
            control_direction_latent.y = control_direction.y


func _apply_jump_force() -> void:
    if WALL_JUMP_ENABLED:
        if wall_coyote_active and wall_direction != 0:
            velocity = Vector2(-wall_direction * WALL_JUMP_FORCE_X, -WALL_JUMP_FORCE_Y)
            return

    velocity.y = -JUMP_FORCE
    jumps_left -= 1


func _try_perform_jump() -> bool:
    if coyote_active or jumps_left > 0 or wall_coyote_active:
        _apply_jump_force()
        coyote_active = false
        wall_coyote_active = false
        jump_triggered = false
        return true
    return false


func trigger_jump() -> void:
    var result: bool = _try_perform_jump()
    if !result:
        if !jump_triggered:
            jump_triggered = true
            jump_buffer_timer.start()


func _update_jump_conditions(_delta: float) -> void:
    if is_on_floor():
        jumps_left = JUMP_NUM_MAX
        coyote_active = true
        coyote_timer.set_paused(true)
    else:
        if coyote_timer.paused:
            coyote_timer.set_paused(false)
            coyote_timer.start()

    if _is_colliding_wall():
        wall_coyote_active = true
        wall_coyote_timer.set_paused(true)
    else:
        if wall_coyote_timer.paused:
            wall_coyote_timer.set_paused(false)
            wall_coyote_timer.start()


func _on_buffer_jump_timeout() -> void:
    if !jump_triggered:
        return
    jump_triggered = false
    _try_perform_jump()


func _on_coyote_timeout() -> void:
    if coyote_active:
        jumps_left -= 1
        coyote_active = false


func _on_wall_coyote_timeout() -> void:
    wall_coyote_active = false


func _is_colliding_wall() -> bool:
    return false


func _process_gravity(delta: float) -> void:
    if is_on_floor():
        control_direction_scale = 1
    else:
        control_direction_scale = AIR_CONTROL

    var new_velocity: float = velocity.y + gravity * GRAVITY_SCALE * delta
    velocity.y = clamp(new_velocity, -TERMINAL_VELOCITY_VERTICAL, TERMINAL_VELOCITY_VERTICAL)


func _process_movement(_delta: float) -> void:
    var new_velocity: float = velocity.x
    if control_direction.x == 0:
        new_velocity = move_toward(new_velocity, control_direction_latent.x * SPEED * (1. - AIR_FRICTION), DECELERATION)
    else:
        new_velocity = move_toward(new_velocity, control_direction.x * SPEED * control_direction_scale, ACCELERATION)

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
