extends Node2D

@export var text: String
@export var initially_shown: bool = false
@onready var regex: RegEx = RegEx.new()


func _cleanup_name(_name: String) -> String:
	return regex.sub(_name, "")


func _replace_text(_text: String, _action_name: String, _event: InputEvent) -> String:
	return _text.replace('{'+_action_name+"}", _cleanup_name(_event.as_text()))


func template_text(_text: String) -> String:

	var _template: String = _text

	for action_name in AppSettings.get_action_names():
		var action_events: Array[InputEvent] = InputMap.action_get_events(action_name)
		
		for event in action_events:
			_template = _replace_text(_template, action_name, event)

	return _template


func _ready()->void:
	regex.compile("\\(.*?\\)")
	%Label.text = text
	%Label.text = template_text(text)
	if initially_shown:
		%Label.visible = true
	
func _on_area_2d_body_entered(body: Node2D) -> void:
	if body is PlayerCharacter:
		%Label.text = template_text(text)
		%Label.visible = true


func _on_area_2d_body_exited(body: Node2D) -> void:
	if body is PlayerCharacter:
		%Label.visible = false
