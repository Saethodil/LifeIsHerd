extends TooltipTracker

class_name TooltipMovementTracker

var pressed_movement_directions = {
	&"ui_left": false,
	&"ui_right": false,
	&"ui_up": false,
	&"ui_down": false
}

func _physics_process(_delta: float):
	for direction in pressed_movement_directions:
		if Input.is_action_just_pressed(direction) || pressed_movement_directions[direction]:
			pressed_movement_directions[direction] = true
	if !is_finished && pressed_movement_directions.values().all(func(value): return value):
		_on_finish()
