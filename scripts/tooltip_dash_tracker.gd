extends TooltipTracker

class_name TooltipDashTracker

func _ready():
	matador.dash_started.connect(_on_dash_started)
	
func _on_dash_started():
	if is_finished:
		return
		
	_on_finish()
