extends TooltipTracker

class_name TooltipParryTracker

func _ready():
	matador.parry_started.connect(_on_parry_started)
	
func _on_parry_started():
	if is_finished:
		return
		
	_on_finish()
