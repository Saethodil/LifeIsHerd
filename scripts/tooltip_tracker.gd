extends Node

class_name TooltipTracker

signal finished

var is_finished = false
var bull: Bull
var matador: Matador

func setup(context_bull: Bull, context_matador: Matador):
	bull = context_bull
	matador = context_matador

func _on_finish():
	is_finished = true
	finished.emit()
