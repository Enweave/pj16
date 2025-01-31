extends CharacterWithHealth
class_name GroundEnemyBase

@export_category("AI")
@export var patrol_enabled: bool = true
@export var patrol_walk_time: float = 2
@export var patrol_wait_time: float = 1
@export var chase_enabled: bool = true
@export var score_cost: int = 100

func _ready() -> void:
    super._ready()
    health_component.OnDeath.connect(_on_death)


func _on_death() -> void:
    call_deferred("queue_free")
    FlowControllerAutoload.earn_score(score_cost)