extends Node2D

@onready var game_manager_container: Node = $GameManagerContainer
@onready var game_pause_container: Node = $GamePauseContainer
@onready var menu_container: Node = $MenuContainer
@onready var background_music_player: AudioStreamPlayer = $BackgroundMusicPlayer

var pause_previous_focus_owner: Control

const MENU_SCENE: PackedScene = preload("res://scenes/menu.tscn")
const BULL_SCENE: PackedScene = preload("res://scenes/bull_selection.tscn")
const CREDITS_SCENE: PackedScene = preload("res://scenes/credits.tscn")
const SETTINGS_SCENE: PackedScene = preload("res://scenes/settings.tscn")
const GAME_MANAGER_SCENE: PackedScene = preload("res://scenes/game_manager.tscn")
const GAME_PAUSE_SCENE: PackedScene = preload("res://scenes/game_pause.tscn")

var main_menu: Menu:
	get():
		return menu_container.get_child(0)
		
var game: Game:
	get():
		return (game_manager_container.get_child(0) as GameManager).game

var game_pause: GamePause:
	get():
		return game_pause_container.get_child(0)

var _game_is_pausable: bool = false

func _unhandled_input(_event: InputEvent):
	if Input.is_action_just_pressed("pause"):
		_show_pause_menu()
		get_viewport().set_input_as_handled()

func _initiate_game():
	_init_game_state()
	_show_main_menu()
	_show_game()
	
func _init_game_state(): 
	GameState.set_data_value(GameState.DATA_KEY_BULL_EASY, true)
	GameState.set_data_value(GameState.DATA_KEY_BULL_NORMAL, false)
	GameState.set_data_value(GameState.DATA_KEY_BULL_HARD, false)
	GameState.set_data_value(GameState.DATA_KEY_BULL_BEATEN_EASY , 0)
	GameState.set_data_value(GameState.DATA_KEY_BULL_BEATEN_NORMAL , 0)
	GameState.set_data_value(GameState.DATA_KEY_BULL_BEATEN_HARD , 0)

func _show_main_menu(is_intro_animation_enabled: bool = true):
	var menu_scene = MENU_SCENE.instantiate() as Menu
	menu_scene.play_requested.connect(_on_menu_play_requested)
	menu_scene.is_intro_animation_enabled = is_intro_animation_enabled
	menu_scene.credits_requested.connect(_on_menu_credits_requested)
	menu_scene.settings_requested.connect(_on_menu_settings_requested)
	menu_container.add_child(menu_scene)

func _on_menu_game_transition_started():
	background_music_player.stop()

func _show_game(entrance_animated: bool = true):
	var game_manager_scene = GAME_MANAGER_SCENE.instantiate() as GameManager
	game_manager_scene.entrance_animated = entrance_animated
	game_manager_scene.menu_requested.connect(_on_game_menu_requested.bind(game_manager_scene))
	game_manager_container.add_child(game_manager_scene)

func _on_menu_play_requested():
	var bull_selection = BULL_SCENE.instantiate() as MenuBullSelection
	bull_selection.back_pressed.connect(_on_bull_selection_back_pressed)
	bull_selection.game_started.connect(_on_bull_selection_play_pressed)
	menu_container.add_child(bull_selection)
	main_menu.hide()
	
func _on_menu_credits_requested():
	var credits = CREDITS_SCENE.instantiate() as MenuCredits
	credits.back_pressed.connect(_on_credits_back_pressed)
	menu_container.add_child(credits)
	main_menu.hide()
	
func _on_menu_settings_requested():
	var settings = SETTINGS_SCENE.instantiate() as MenuSettings
	settings.back_pressed.connect(_on_settings_back_pressed)
	menu_container.add_child(settings)
	main_menu.hide()

func _on_game_menu_requested(game_manager: GameManager):
	_show_main_menu(false)
	# Reset game state for next playthrough
	game_manager.queue_free()
	_show_game(true)

func _on_game_menu_requested_pause():
	_resume_game(false)
	_on_game_menu_requested(game_manager_container.get_child(0) as GameManager)

func _on_game_resume_requested_pause():
	_resume_game(true)

func _resume_game(is_pausable: bool):
	_game_is_pausable = is_pausable
	game_pause.queue_free()
	game.get_tree().paused = false
	_restore_previous_focus_if_needed()

func _show_pause_menu():
	if _game_is_pausable:
		_game_is_pausable = false
		_save_previous_focus_if_needed()
		game.get_tree().paused = true
		
		var game_pause_scene = GAME_PAUSE_SCENE.instantiate() as GamePause
		game_pause_scene.resume_requested.connect(_on_game_resume_requested_pause)
		game_pause_scene.menu_requested.connect(_on_game_menu_requested_pause)
		game_pause_container.add_child(game_pause_scene)

func _save_previous_focus_if_needed():
	pause_previous_focus_owner = game.get_viewport().gui_get_focus_owner()
	
func _restore_previous_focus_if_needed():
	if pause_previous_focus_owner:
		pause_previous_focus_owner.grab_focus()
		pause_previous_focus_owner = null

func _on_bull_selection_back_pressed():
	main_menu.show()
	main_menu.play_button.grab_focus()
	
func _on_bull_selection_play_pressed(bull_meta: BullMeta):
	game.start(bull_meta)
	main_menu.queue_free()
	_game_is_pausable = true
	
func _on_credits_back_pressed():
	main_menu.show()
	main_menu.credits_button.grab_focus()
	
func _on_settings_back_pressed():
	main_menu.show()
	main_menu.settings_button.grab_focus()

func _on_particle_preloader_completed() -> void:
	background_music_player.play()
	_initiate_game()
