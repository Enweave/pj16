extends Node
class_name GroundEnemyAi

@export_category("AI")
@export var vision_area: EnemyVisionArea = null
@export var attack_range: float = 30
@export var patrol_range: float = 100
@export var current_weapon: WeaponBase = null

var _target: CharacterBase = null
var _is_patrolling: bool   = true
enum Behaviour {
    Idle,
    Patrol,
    Chase,
    Attack,
}
var controlled_character: CharacterBase = null


# Called when the node enters the scene tree for the first time.
func _ready() -> void:

    pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:

    pass
