extends TooltipTracker

class_name TooltipWaveTracker

func _ready():
	bull.state_changed.connect(_on_bull_state_changed)
	
func _on_bull_state_changed(state: Bull.State):
	if is_finished:
		return
	if state == Bull.State.ANGRY:
		_on_finish()
