extends Node2D

@export var platform: MovingPlatform


@onready var anim_player: AnimationPlayer = %AnimationPlayer
@export var oneshot: bool = true

@onready var sfx_player: RandomSFXPlayer = %RandomSFXPlayer
var _is_triggered: bool = false


func _on_trigger_area_2d_body_entered(body: Node) -> void:
	if _is_triggered:
		return
	
	if body is PlayerCharacter:
		_is_triggered = true
		platform.trigger()
#		sfx_player.play_random_sound()
		anim_player.play("down")


func _on_trigger_area_2d_body_exited(body: Node) -> void:
	if oneshot:
		return
	if !_is_triggered:
		return
	_is_triggered = false

	if body is PlayerCharacter:
		anim_player.play("up")