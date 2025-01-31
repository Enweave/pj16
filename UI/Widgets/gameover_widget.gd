extends Control

class_name GameoverWidget

func _ready() -> void:
    %ButtonRetry.grab_focus()

func _on_button_retry_pressed() -> void:
    FlowControllerAutoload.restart_level()
    
    
func _on_button_menu_pressed() -> void:
    FlowControllerAutoload.load_main_menu()