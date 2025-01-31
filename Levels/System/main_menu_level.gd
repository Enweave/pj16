extends LevelBase

func _ready():
	super._ready()
	var b: Node = get_node_or_null("%StartGameButton")
	if b:
		b.grab_focus()
	
func _on_start_game_button_pressed():
	FlowControllerAutoload.load_next_level()
	
func _on_settings_button_pressed():
	FlowControllerAutoload.display_settings_menu()
