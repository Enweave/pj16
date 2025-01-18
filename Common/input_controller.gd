extends Node
class_name InputController

enum InputActions {
    Pause,
    MoveUp,
    MoveDown,
    MoveLeft,
    MoveRight,
    Jump,
    Fire,
    Inventory0,
    Inventory1,
    Inventory2,
}

var input_actions: Dictionary = {
    InputActions.Pause: "input_Pause",
    InputActions.MoveUp: "input_MoveUp",
    InputActions.MoveDown: "input_MoveDown",
    InputActions.MoveLeft: "input_MoveLeft",
    InputActions.MoveRight: "input_MoveRight",
    InputActions.Jump: "input_Jump",
    InputActions.Fire: "input_Fire",
    InputActions.Inventory0: "input_Inventory0",
    InputActions.Inventory1: "input_Inventory1",
    InputActions.Inventory2: "input_Inventory2",
}


func _unhandled_input(event):
    if event is InputEventKey:
        if event.is_action_pressed(input_actions[InputActions.Pause]):
            FlowControllerAutoload.toggle_pause_game()