class_name GameManager

extends Node2D

signal menu_requested

@export var entrance_animated = false

@onready var game_container = %GameContainer

var game: Game

const GAME_SCENE = preload("res://scenes/game.tscn")

func _ready():
	game_container.add_child(_create_game(entrance_animated))
	
func _input(event: InputEvent) -> void:
	if event.is_action("ui_menu"):
		menu_requested.emit()
		
func _create_game(animated: bool) -> Game:
	game = GAME_SCENE.instantiate()
	game.entrance_animated = animated
	game.menu_requested.connect(_on_game_menu_requested)
	game.play_requested.connect(_on_game_play_requested)
	return game
	
func _on_game_menu_requested():
	menu_requested.emit()
	
func _on_game_play_requested():
	var current_bull_meta = game.bull.meta
	game.queue_free()
	game = _create_game(true)
	game.is_intro_music_enabled = false
	game_container.add_child(game)
	game.start(current_bull_meta)
