class_name GamePause
extends CanvasLayer

signal resume_requested
signal menu_requested

@onready var resume_button: Button = %ResumeButton
@onready var menu_button: Button = %MenuButton

func _ready():
	resume_button.grab_focus()

func _on_resume_button_pressed():
	resume_requested.emit()

func _on_menu_button_pressed():
	menu_requested.emit()
