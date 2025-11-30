class_name MenuSettings
extends CanvasLayer

signal back_pressed

@onready var back_button = %BackButton
@onready var volume_change_sound_player = $VolumeChangeSoundPlayer
@onready var music_volume_slider = %MusicVolumeSlider
@onready var sfx_volume_slider = %SFXVolumeSlider
@onready var shake_toggle = %ShakeToggle

func _ready():
	back_button.grab_focus()
	sfx_volume_slider.value_changed.connect(_on_volume_slider_value_changed)
	if GameState.has_data_value(GameState.DATA_KEY_SCREEN_SHAKE):
		shake_toggle.button_pressed = GameState.get_data_value(GameState.DATA_KEY_SCREEN_SHAKE)
	else:
		shake_toggle.button_pressed = true

func _on_back_button_pressed():
	back_pressed.emit()
	queue_free()

func _on_volume_slider_value_changed(_value: float):
	volume_change_sound_player.play()

func _on_shake_toggle_toggled(toggled_on: bool) -> void:
	GameState.set_data_value(GameState.DATA_KEY_SCREEN_SHAKE, toggled_on)
