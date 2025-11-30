class_name MenuBullSelection
extends CanvasLayer

@onready var back_button: Button = %BackButton
@onready var bull_button_container: Control = %BullButtonContainer
@onready var name_value: Label = %NameValue
@onready var difficulty_value: Label = %DifficultyValue
@onready var biography_value: Label = %BiographyValue
@onready var play_button: Button = %PlayButton

signal back_pressed
signal game_started(bull_meta: BullMeta)

const BULL_EASY = preload("res://scripts/bull/resources/bull_meta_easy.tres")
const BULL_NORMAL = preload("res://scripts/bull/resources/bull_meta_normal.tres")
const BULL_HARD = preload("res://scripts/bull/resources/bull_meta_hard.tres")
const CHECKMARK = preload("res://assets/sprites/checkmark.png")
const CHECKMARK_FLAWLESS = preload("res://assets/sprites/checkmark-flawless.png")

var bull_meta_items: Array[BullMeta]:
	get():
		return [BULL_EASY, BULL_NORMAL, BULL_HARD]

var selected_bull_meta: BullMeta

func _ready() -> void:
	_setup_buttons()
	
	var preferred_button_index: int
	for button_index in range(0, bull_button_container.get_children().size()):
		if !bull_button_container.get_child(button_index).disabled:
			preferred_button_index = button_index
	
	_activate_bull(bull_button_container.get_child(
		preferred_button_index), 
		bull_meta_items[preferred_button_index]
	)
	back_button.grab_focus()
	
func _setup_buttons():
	var bull_button_group = ButtonGroup.new()
	bull_button_group.allow_unpress = false
	
	for bull_meta in bull_meta_items:
		bull_button_container.add_child(_create_bull_button(
			bull_meta,
			bull_button_group, 
			GameState.get_data_value(GameState.DIFFICULTY_UNLOCKED_KEYS[bull_meta.difficulty_key]), 
			GameState.get_data_value(GameState.DIFFICULTY_BEATEN_KEYS[bull_meta.difficulty_key])
		))
	
func _create_bull_button(bull_meta: BullMeta, button_group: ButtonGroup, enabled: bool, beaten_status: int) -> TextureButton:
	var button = TextureButton.new()
	button.toggle_mode = true
	button.button_group = button_group
	button.texture_normal = bull_meta.icon_normal
	button.texture_hover = bull_meta.icon_focused
	button.texture_focused = bull_meta.icon_focused
	button.texture_disabled = bull_meta.icon_disabled
	button.texture_pressed = bull_meta.icon_active

	button.focus_entered.connect(_on_bull_button_focus_entered.bind(button, bull_meta))
	
	if !enabled:
		button.disabled = true
		button.focus_mode = Control.FOCUS_NONE
	
	if beaten_status:
		var status_rect = TextureRect.new()
		status_rect.texture = CHECKMARK_FLAWLESS if beaten_status == GameState.DATA_VALUE_BULL_BEATEN_FLAWLESS else CHECKMARK
		button.add_child(status_rect)
		status_rect.position = bull_meta.icon_normal.get_size() - Vector2(4, 4)
		
	return button
	
func _on_back_button_pressed():
	back_pressed.emit()
	queue_free()

func _on_play_button_pressed():
	game_started.emit(selected_bull_meta)
	queue_free()
	
func _on_bull_button_focus_entered(button: TextureButton, bull_meta: BullMeta):
	_activate_bull(button, bull_meta)
	
func _activate_bull(button: TextureButton, bull_meta: BullMeta):
	if button.disabled:
		return
		
	var previous_pressed_button = button.button_group.get_pressed_button()
	if previous_pressed_button:
		var previous_bull_meta = bull_meta_items[previous_pressed_button.get_index()]
		previous_pressed_button.texture_hover = previous_bull_meta.icon_focused
		previous_pressed_button.texture_focused = previous_bull_meta.icon_focused
	
	button.button_pressed = true
	button.texture_hover = bull_meta.icon_active_focused
	button.texture_focused = bull_meta.icon_active_focused
	
	name_value.text = bull_meta.name
	
	difficulty_value.text = bull_meta.difficulty
	biography_value.text = bull_meta.bio

	var button_path = button.get_path()
	play_button.focus_neighbor_top = button_path
	back_button.focus_neighbor_bottom = button_path
	back_button.focus_neighbor_right = button_path

	selected_bull_meta = bull_meta
