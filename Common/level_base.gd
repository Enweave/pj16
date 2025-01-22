@tool
extends Node
class_name LevelBase

@export var next_level_scene: PackedScene:
	set(value):
		next_level_scene = value
		if next_level_scene != null:
			next_level_path = next_level_scene.resource_path
		else:
			next_level_path = ""
		next_level_scene = null

@export var next_level_path: String
@export var allow_pause_menu: bool = true


func _ready():
	if Engine.is_editor_hint() == false:
		FlowControllerAutoload.set_current_level(self)
		if next_level_path != null:
			FlowControllerAutoload.set_next_level_scene_path(next_level_path)
