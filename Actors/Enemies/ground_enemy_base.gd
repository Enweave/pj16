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
	var score_widget : ScoreFx = load("res://Actors/FX/score_fx.tscn").instantiate()
	score_widget.score = score_cost
	score_widget.position = global_position
	FlowControllerAutoload.add_child_to_level(score_widget)
