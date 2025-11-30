class_name Menu

extends CanvasLayer

signal play_requested
signal credits_requested
signal settings_requested

@export var is_intro_animation_enabled = true

@onready var play_button: Button = %Play
@onready var settings_button: Button = %Settings
@onready var credits_button: Button = %Credits
@onready var title: Sprite2D =  $MarginContainer2/Title
@onready var animation_player: AnimationPlayer = $MarginContainer2/Title/AnimationPlayer
@onready var menu: VBoxContainer = $MarginContainer/Menu

func _ready() -> void:
	_show_title()
	
func _show_title() -> void:
	if is_intro_animation_enabled:
		var tween = get_tree().create_tween()
		tween.set_ease(Tween.EASE_IN_OUT)
		tween.set_trans(Tween.TRANS_CUBIC)
		tween.set_parallel()
		tween.tween_property(title, "modulate", Color.WHITE, 3)
		tween.tween_property(title, "position", Vector2(title.position.x, title.position.y - 88), 3)
		await tween.finished
	else:
		title.modulate = Color.WHITE
		title.position = Vector2(title.position.x, title.position.y - 88)
		
	_show_menu()
	
func _show_menu() -> void:
	menu.visible = true
	play_button.grab_focus()
	animation_player.play("bounce")
	var tween = get_tree().create_tween()
	tween.tween_property(menu, "modulate", Color.WHITE, 2)
	tween.tween_callback(_setup_menu)
	
func _setup_menu() -> void:
	menu.mouse_filter = Control.MOUSE_FILTER_PASS

func _on_play_pressed() -> void:
	play_requested.emit()


func _on_settings_pressed() -> void:
	settings_requested.emit()


func _on_credits_pressed() -> void:
	credits_requested.emit()
