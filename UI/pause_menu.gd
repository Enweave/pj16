extends Control

class_name PauseMenu

func _on_resume_button_pressed():
    FlowControllerAutoload.toggle_pause_game()
    
    
func _on_main_menu_button_pressed():
    FlowControllerAutoload.load_main_menu()
    
    
func _on_retry_button_pressed():
    FlowControllerAutoload.restart_level()