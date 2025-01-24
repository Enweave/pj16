extends CustomStateMachinePlayer
class_name GroundEnemyAi

@export_category("AI")
@export var vision_area : EnemySensorArea = null
@export var attack_area : EnemySensorArea = null
@export var current_weapon : WeaponBase = null
@export var patrol_range : float = 100

var _target : CharacterBase = null

enum BehaviourKeys {
    Patrol ,
    Chase ,
    Attack
}

const BEHAVIOURS : Dictionary = {
    BehaviourKeys.Patrol : "Patrol" ,
    BehaviourKeys.Chase : "Chase" ,
    BehaviourKeys.Attack : "Attack"
}

var controlled_character : CharacterBase = null


func _ready() -> void :
    if vision_area != null:
        pass

    # connect vision signals
    pass

    
func _on_vision_entered(body) -> void:
    if body is PlayerCharacter:
        _target = body
        return


func _process(_delta : float) -> void :
    pass


func _on_state_changed(from , to) -> void :
    match to :
        BEHAVIOURS[BehaviourKeys.Patrol] :
            print('patrolling')
        BEHAVIOURS[BehaviourKeys.Chase] :
            print('chasing')
        BEHAVIOURS[BehaviourKeys.Attack] :
            print('attacking')