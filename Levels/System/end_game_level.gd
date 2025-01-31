extends LevelBase

func _ready() -> void:
    super._ready()
    %score.text = "total score: " + str(FlowControllerAutoload.player_state.get_score())


func _on_main_menu_button_pressed():
    FlowControllerAutoload.load_main_menu()