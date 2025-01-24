extends Node2D
class_name GroundEnemyAi

@export_category("AI")

@export var vision_area: EnemySensorArea = null
@export var attack_area: EnemySensorArea = null
@export var current_weapon: WeaponBase = null
@export var patrol_walk_time: float = 2
@export var patrol_wait_time: float = 1

@onready var _patrol_timer: Timer = %PatrolTimer

var _patrol_direction: Vector2 = Vector2.RIGHT
var _patrol_wait: bool = false
var _current_behaviour: BehaviourKeys = BehaviourKeys.Patrol
var _target: CharacterBase = null
enum BehaviourKeys {
    Patrol,
    Chase,
    Attack
}
const BEHAVIOURS: Dictionary = {
    BehaviourKeys.Patrol: "Patrol",
    BehaviourKeys.Chase: "Chase",
    BehaviourKeys.Attack: "Attack"
}
var controlled_character: CharacterBase


func _ready() -> void:
    if owner != null and owner is CharacterBase:
        controlled_character = owner

        if vision_area != null:
            vision_area.body_entered.connect(_on_vision_entered)
            vision_area.body_exited.connect(_on_vision_exited)
    
        if attack_area != null:
            attack_area.body_entered.connect(_on_attack_sensor_entered)
            attack_area.body_exited.connect(_on_attack_sensor_exited)
    
        %StateMachinePlayer.connect("transited", _on_StateMachinePlayer_transited)
    
        _patrol_timer.wait_time = patrol_walk_time
        _patrol_timer.timeout.connect(_on_patrol_timer_timeout)


func _on_patrol_timer_timeout() -> void:
    _patrol_wait = !_patrol_wait
    if !_patrol_wait:
        _patrol_direction = -_patrol_direction

    if _current_behaviour == BehaviourKeys.Patrol:
        if _patrol_wait:
            _patrol_timer.wait_time = patrol_wait_time
            controlled_character.set_control_direction(Vector2.ZERO)
        else:
            _patrol_timer.wait_time = patrol_walk_time
            controlled_character.set_control_direction(_patrol_direction)
        _patrol_timer.start()


func _on_vision_entered(body) -> void:
    if body is PlayerCharacter:
        _target = body
        %StateMachinePlayer.set_param("PlayerVisible", true)


func _on_vision_exited(body) -> void:
    if _target == body:
        %StateMachinePlayer.set_param("PlayerVisible", false)


func _on_attack_sensor_entered(body) -> void:
    if body is PlayerCharacter:
        _target = body
        %StateMachinePlayer.set_param("PlayerVisible", true)
        %StateMachinePlayer.set_param("PlayerInRange", true)


func _on_attack_sensor_exited(body) -> void:
    if _target == body:
        %StateMachinePlayer.set_param("PlayerInRange", false)


func _chase(_delta)-> void:
    if _target != null:
        var direction: Vector2 = _target.position - controlled_character.position
        direction = direction.normalized()
        controlled_character.set_control_direction(direction)


func _attack(_delta) -> void:
    if _target != null:
        var direction: Vector2 = _target.position - controlled_character.position
        direction = direction.normalized()
        
        controlled_character.set_latent_control_direction(direction)
        if current_weapon != null:
            current_weapon.set_target(direction, _target.global_position, _target)
            current_weapon.activate()


func _process(_delta: float) -> void:
    match _current_behaviour:
        BehaviourKeys.Chase:
            _chase(_delta)
        BehaviourKeys.Attack:
            _attack(_delta)


func _on_StateMachinePlayer_transited(_from, to) -> void:
    match to:
        BEHAVIOURS[BehaviourKeys.Patrol]:
            _current_behaviour = BehaviourKeys.Patrol
            _patrol_timer.start()
        BEHAVIOURS[BehaviourKeys.Chase]:
            _patrol_timer.stop()
            _current_behaviour = BehaviourKeys.Chase
        BEHAVIOURS[BehaviourKeys.Attack]:
            _patrol_timer.stop()
            _current_behaviour = BehaviourKeys.Attack
            controlled_character.set_control_direction(Vector2.ZERO)