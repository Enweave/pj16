extends Node2D
class_name GroundEnemyAi

@export_category("AI")

@export var vision_area: EnemySensorArea = null
@export var attack_area: EnemySensorArea = null
@export var current_weapon: WeaponBase = null
@export var patrol_range: float = 100


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
var controlled_character: CharacterBase = null


func _ready() -> void:
	if vision_area != null:
		vision_area.body_entered.connect(_on_vision_entered)
		vision_area.body_exited.connect(_on_vision_exited)

	if attack_area != null:
		attack_area.body_entered.connect(_on_attack_sensor_entered)
		attack_area.body_exited.connect(_on_attack_sensor_exited)

	%StateMachinePlayer.connect("transited", _on_StateMachinePlayer_transited)

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


func _process(_delta: float) -> void:
	pass


func _on_StateMachinePlayer_transited(_from, to) -> void:
	match to:
		BEHAVIOURS[BehaviourKeys.Patrol]:
			print('patrolling')
		BEHAVIOURS[BehaviourKeys.Chase]:
			print('chasing')
		BEHAVIOURS[BehaviourKeys.Attack]:
			print('attacking')
