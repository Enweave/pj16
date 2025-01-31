extends Control

class_name SettingsMenu

func display_settings():
	self.visible = true
	# focus on the first button
	self.grab_focus()
	
	
func hide_settings():
	self.visible = false
	
func _on_close_button_pressed():
	FlowControllerAutoload.hide_settings_menu()
