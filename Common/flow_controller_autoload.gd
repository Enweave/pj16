extends Node

const FADE_DURATION: float = 0.15

var current_level: LevelBase
var input_controller: InputController
var next_level_scene_path: String   = ""
const main_menu_level_path: String  = "res://Levels/System/main_menu_level.tscn"
const end_game_level_path: String   = "res://Levels/System/end_game_level.tscn"
const game_over_widget_path: String = "res://UI/Widgets/gameover_widget.tscn"
const pause_menu_path: String       = "res://UI/pause_menu.tscn"
const ingame_ui_path: String        = "res://UI/ingame_ui.tscn"
const settings_menu_path: String    = "res://UI/settings_menu.tscn"
var current_pause_menu: PauseMenu
var current_game_over_widget: GameoverWidget
var viewport_container: SubViewportContainer
var viewport: SubViewport
var ingame_ui: IngameUI
var pause_menu_allowed: bool        = true
var settings_menu_displayed: bool   = false
var settings_menu: SettingsMenu
var player_state: PlayerState

func _ready():
	current_pause_menu = null
	process_mode = Node.PROCESS_MODE_ALWAYS
	input_controller = InputController.new()
	add_child(input_controller)
	viewport_container = SubViewportContainer.new()
	viewport_container.set_visible(false)
	viewport = SubViewport.new()

	await get_tree().get_root().call_deferred("add_child", viewport_container)
	await viewport_container.call_deferred("add_child", viewport)
	viewport_container.set_mouse_filter(Control.MOUSE_FILTER_STOP)
	viewport_container.focus_mode = Control.FOCUS_ALL
	
	# get windows resolution from project settings
	var viewport_size: Vector2 = Vector2(ProjectSettings.get_setting("display/window/size/viewport_width"), ProjectSettings.get_setting("display/window/size/viewport_height"))

	viewport.size = viewport_size
	viewport.handle_input_locally = true
	viewport.canvas_item_default_texture_filter = 0 # DEFAULT_CANVAS_ITEM_TEXTURE_FILTER_NEAREST 

	settings_menu = load(settings_menu_path).instantiate()
	settings_menu.process_mode = Node.PROCESS_MODE_ALWAYS
	await get_tree().get_root().call_deferred("add_child", settings_menu)
	hide_settings_menu()
	player_state = PlayerState.new()
	player_state.reset()
	get_tree().create_timer(0.3).timeout.connect(_on_timeout)


func _on_timeout():
	viewport_container.set_visible(true)
	get_tree().get_root().move_child(viewport_container, 0)


func set_current_level(current_level_in: LevelBase = null):
	current_level = current_level_in
	current_level.call_deferred("reparent", viewport, false)
	pause_menu_allowed = current_level.allow_pause_menu


func set_player_character(player_character_in: PlayerCharacter = null):
	input_controller.set_current_character(player_character_in)
	if ingame_ui == null:
		ingame_ui = load(ingame_ui_path).instantiate()
		await get_tree().get_root().call_deferred("add_child", ingame_ui)
	ingame_ui.assign_player_character(player_character_in)
	ingame_ui.toggle_visibility(true)


func set_next_level_scene_path(next_scene_in: String = ""):
	next_level_scene_path = next_scene_in


func load_main_menu():
	pause_game(false)
	_load_level(main_menu_level_path)


func load_end_game():
	pause_game(false)
	_load_level(end_game_level_path)


func restart_level():
	await pause_game(false)
	if current_level != null:
		# reinstantiate current level
		var level_path: String = current_level.scene_file_path
		_load_level(level_path)


func add_child_to_level(child: Node):
	if current_level != null:
		await (current_level.call_deferred("add_child", child))
	else:
		await (get_tree().get_current_scene().call_deferred("add_child", child))

	
func add_fx_to_level(in_fx: FX_Helper.FX_TYPE, in_position: Vector2, in_scale: Vector2 = Vector2.ONE, in_rotation: float = 0.0, parent: Node2D = null):
	var fx : Node = load(FX_Helper.get_fx_path(in_fx)).instantiate()
	fx.global_position = in_position
	fx.global_scale = in_scale
	fx.rotation = in_rotation
	if parent == null:
		add_child_to_level(fx)
	else:
		parent.call_deferred("add_child", fx)


	

func _load_level(level_path: String):
	var tween: Tween = get_tree().create_tween()
	tween.set_pause_mode(Tween.TWEEN_PAUSE_PROCESS)
	tween.tween_property(viewport_container, 'modulate:a', 0, FADE_DURATION)
	get_tree().paused = true
	await tween.finished
	if ingame_ui != null:
		ingame_ui.toggle_visibility(false)
	pause_game(false)
	_toggle_gameover_widet(false)
	print("Loading level: " + level_path)

	if current_level == null:
		# get current scene
		get_tree().get_current_scene().call_deferred("queue_free")
	else:
		await(current_level.call_deferred("queue_free"))
	var level: Node = load(level_path).instantiate()
	await viewport.call_deferred('add_child', level)
	
	# fade-in fade-out effect using tween and opacity on viewport container
	get_tree().paused = false
	tween = get_tree().create_tween()
	tween.tween_property(viewport_container, 'modulate:a', 1, FADE_DURATION)
	

func load_next_level():
	if next_level_scene_path != "":
		_load_level(next_level_scene_path)
	else:
		print("No next level scene set")
		load_end_game()


func add_remove_pause_menu(pause: bool):
	if current_pause_menu != null:
		await current_pause_menu.call_deferred("queue_free")
		current_pause_menu = null
	if pause and pause_menu_allowed:
		current_pause_menu = load(pause_menu_path).instantiate()
		current_pause_menu.process_mode = Node.PROCESS_MODE_ALWAYS
		get_tree().get_root().add_child(current_pause_menu)


func _toggle_gameover_widet(show: bool):
	if current_game_over_widget != null:
		await current_game_over_widget.call_deferred("queue_free")
		current_game_over_widget = null
	if show:
		current_game_over_widget = load(game_over_widget_path).instantiate()
		current_game_over_widget.process_mode = Node.PROCESS_MODE_ALWAYS
		get_tree().get_root().add_child(current_game_over_widget)


func new_game():
	player_state.reset()

func game_over():
	get_tree().paused = true
	_toggle_gameover_widet(true)


func pause_game(pause: bool):
	add_remove_pause_menu(pause)
	if pause:
		if pause_menu_allowed:
			get_tree().paused = true
	else:
		get_tree().paused = false


func toggle_pause_game() -> void:
	if current_game_over_widget != null:
		return
	pause_game(not get_tree().paused)

	
func display_settings_menu():
	settings_menu_displayed = true
	settings_menu.display_settings()
	get_tree().get_root().move_child(settings_menu, -1)

func hide_settings_menu():
	settings_menu_displayed = false
	settings_menu.hide_settings()
	
func handle_pause_input():
	if settings_menu_displayed:
		hide_settings_menu()
	else:
		toggle_pause_game()
