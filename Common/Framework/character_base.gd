extends CharacterBody2D
class_name CharacterBase

var gravity: float = ProjectSettings.get_setting("physics/2d/default_gravity") as float

@export_group("Movement")
@export var SPEED: float = 200
@export var AIR_CONTROL: float = 1
@export var AIR_FRICTION : float = 0.7
@export var ACCELERATION: float = 20
@export var GRAVITY_SCALE: float = 1
@export var TERMINAL_VELOCITY_HORIZONTAL: float = 500
@export var TERMINAL_VELOCITY_VERTICAL: float = 400

var DECELERATION: float               = SPEED/10
var control_direction: Vector2        = Vector2.ZERO
var control_direction_latent: Vector2 = Vector2.ZERO
var control_direction_scale: float    = 1

@export_group("Jump")
@export var JUMP_FORCE: float = 300.
@export var JUMP_NUM_MAX: int = 1
@export var JUMP_INPUT_BUFFER_TIME: float = 0.1
@export var JUMP_COYOTE_TIME: float = 0.15
@export_group("Wall Jump")
@export var WALL_JUMP_ENABLED: bool = true
@export var WALL_JUMP_FORCE_Y: float = 275.
@export var WALL_JUMP_FORCE_X: float = 338.
@export_group("Misc")
@export var PUSH_RIGID_BODIES: bool = false
@export var PUSH_RIGID_BODIES_FORCE: int = 2
signal jump_started
signal landed


func _ready():
    pass


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


func trigger_jump() -> void:
    if is_on_floor():
        velocity.y = -JUMP_FORCE


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
    if PUSH_RIGID_BODIES:
        _push_rigid_bodies(delta)
