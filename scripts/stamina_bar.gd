extends Node2D

class_name StaminaBar

@onready var progress_bar: TextureProgressBar = $TextureProgressBar

signal depleted

const ENTRANCE_ANIMATION_DURATION = 0.25
const PROGRESS_CHANGE_ANIMATION_DURATION = 0.25
const SHOW_ANIMATION_DURATION = 0.5

var health_tween: Tween = null

var is_depleted: bool:
	get():
		return current_value <= 0

var max_value: float:
	get():
		return progress_bar.max_value
	set(value):
		progress_bar.max_value = value
		progress_bar.value = value
		_current_value = value

var _current_value: float = 0
var current_value: float:
	get():
		return _current_value

func _ready():
	progress_bar.value = max_value
	progress_bar.modulate.a = 0
	_current_value = max_value

func hit():
	_current_value -= 1
	
	tween_health()
	
	if _current_value <= 0:
		depleted.emit()
		
	await get_tree().create_timer(SHOW_ANIMATION_DURATION).timeout
	progress_bar.modulate.a = 0

func heal():
	if _current_value < max_value:
		_current_value += 1
		tween_health()
	
	await get_tree().create_timer(SHOW_ANIMATION_DURATION).timeout
	progress_bar.modulate.a = 0

func tween_health(): 
	if health_tween:
		health_tween.kill()
		health_tween = null
	
	health_tween = get_tree().create_tween()
	health_tween.set_parallel()
	health_tween.tween_property(
		progress_bar,
		"modulate:a",
		1,
		ENTRANCE_ANIMATION_DURATION
	)
	health_tween.tween_property(
		progress_bar,
		"value",
		_current_value,
		PROGRESS_CHANGE_ANIMATION_DURATION
	)

	await health_tween.finished
