extends CanvasLayer

class_name BullHUD

@onready var root_container: Control = $VBoxContainer
@onready var energy_bar: TextureProgressBar = %EnergyBar
@onready var frustration_bar: TextureProgressBar = %FrustrationBar

const ENERGY_CHANGE_ANIMATION_DURATION = 0.3
const ENERGY_CHANGE_ANIMATION_VALUE_DELTA_THRESHOLD = 10
const SHOW_ANIMATION_DURATION = 0.5
const HIDE_ANIMATION_DURATION = 0.5

var energy_change_tween: Tween = null
var animating_energy_target_value: float = -1

func start():
	var tween = get_tree().create_tween()
	tween.tween_property(root_container, "position:y", 0, SHOW_ANIMATION_DURATION)

func hide_animated():
	var tween = get_tree().create_tween()
	tween.tween_property(root_container, "position:y", -root_container.size.y, HIDE_ANIMATION_DURATION)
	
func update_energy_value(value: float):
	if value == energy_bar.value || value == animating_energy_target_value:
		return
		
	if energy_change_tween:
		energy_change_tween.kill()
		energy_change_tween = null
		
	if abs(value - energy_bar.value) > ENERGY_CHANGE_ANIMATION_VALUE_DELTA_THRESHOLD:
		animating_energy_target_value = value
		energy_change_tween = get_tree().create_tween()
		energy_change_tween.tween_property(
			energy_bar, 
			"value", 
			value, 
			ENERGY_CHANGE_ANIMATION_DURATION
		)
	else:
		energy_bar.value = value
