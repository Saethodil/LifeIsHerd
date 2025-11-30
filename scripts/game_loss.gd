extends CanvasLayer

class_name GameLoss

@onready var status_texture_rect: TextureRect = %StatusTextureRect
@onready var button_container: Control = %ButtonContainer
@onready var menu_button: Button = %MenuButton
@onready var play_button: Button = %PlayButton

signal menu_pressed
signal play_pressed

const TEXTURE_DISPLAY_DURATION = 1.0
const MENU_DISPLAY_DELAY = 0.5
const MENU_DISPLAY_DURATION = 0.5
const HIDE_DURATION = 0.5

func show_animated():
	menu_button.grab_focus()
	var tween = get_tree().create_tween()
	tween.tween_property(status_texture_rect, "modulate:a", 1, TEXTURE_DISPLAY_DURATION)
	tween.tween_property(button_container, "modulate:a", 1, MENU_DISPLAY_DURATION).set_delay(MENU_DISPLAY_DELAY)
	await tween.finished
	
func hide_animated():
	var tween = get_tree().create_tween()
	tween.set_parallel(true)
	tween.tween_property(status_texture_rect, "modulate:a", 0, HIDE_DURATION)
	tween.tween_property(button_container, "modulate:a", 0, HIDE_DURATION)
	await tween.finished
	
func _on_menu_button_pressed():
	await hide_animated()
	menu_pressed.emit()

func _on_play_button_pressed():
	await hide_animated()
	play_pressed.emit()
