extends Node

var current_level: LevelBase
var input_controller: InputController

var next_level_scene_path: String = ""
var main_menu_level_path: String = "res://Levels/System/main_menu_level.tscn"
var end_game_level_path: String  = "res://Levels/System/end_game_level.tscn"


func _ready():
    process_mode = Node.PROCESS_MODE_ALWAYS
    input_controller = InputController.new()
    add_child(input_controller)


func set_current_level(current_level_in: LevelBase = null):
    current_level = current_level_in


func set_next_level_scene_path(next_scene_in: String = ""):
    next_level_scene_path = next_scene_in


func load_main_menu():
    _load_level(main_menu_level_path)


func load_end_game():
    _load_level(end_game_level_path)


func restart_level():
    get_tree().reload_current_scene()
    

func _load_level(level_path: String):
    print("Loading level: " + level_path)
    await(current_level.call_deferred("queue_free"))
    var level: Node = load(level_path).instantiate()
    get_tree().get_root().add_child(level)


func load_next_level():
    if next_level_scene_path != "":
        _load_level(next_level_scene_path)
    else:
        print("No next level scene set")
        load_end_game()


func pause_game(pause: bool):
    if pause:
        get_tree().paused = true
    else:
        get_tree().paused = false


func toggle_pause_game():
    pause_game(not get_tree().paused)