extends Node

var current_level: LevelBase
var next_level_scene_path: String = ""


func _ready():
    process_mode = Node.PROCESS_MODE_ALWAYS


func set_current_level(current_level_in: LevelBase = null):
    current_level = current_level_in


func set_next_level_scene_path(next_scene_in: String = ""):
    next_level_scene_path = next_scene_in


func restart_level():
    get_tree().reload_current_scene()


func load_next_level():
    if next_level_scene_path != "":
        var next_level: Node = load(next_level_scene_path).instantiate()
        await current_level.call_deferred("queue_free")
        get_tree().get_root().add_child(next_level)
    else:
        print("No next level scene set")


func pause_game(pause: bool):
    if pause:
        get_tree().paused = true
    else:
        get_tree().paused = false


func _unhandled_input(event):
    if event is InputEventKey:
        if event.is_action_pressed("input_Pause"):
            pause_game(not get_tree().paused)