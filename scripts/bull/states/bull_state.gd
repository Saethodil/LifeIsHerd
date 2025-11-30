extends Node

class_name BullState

signal state_transition_requested(new_state: Bull.State)

var bull: Bull

func setup(context_bull: Bull):
	bull = context_bull
