extends CanvasLayer

class_name GameCountdown

signal countdown_started
signal countdown_tick
signal countdown_finished

@export var countdown_amount = 3

@onready var root_container: Control = $CenterContainer
@onready var label: Label = %Label 

const COUNTDOWN_DISPLAY_DURATION = 1.0

func start():
	countdown_started.emit()
	for count in range(countdown_amount, 0, -1):
		countdown_tick.emit()
		await display("| " + str(count) + " |")
	countdown_finished.emit()
	await display("GO!!")
	
func display(text: String):
	label.text = text
	root_container.modulate.a = 1.0
	var tween = get_tree().create_tween()
	tween.set_ease(Tween.EASE_IN)
	tween.set_trans(Tween.TRANS_CUBIC)
	tween.tween_property(root_container, "modulate:a", 0.0, COUNTDOWN_DISPLAY_DURATION)
	await tween.finished
	
	
