extends BullState

class_name BullEnterState

const BULL_DISTANCE_THRESHOLD = 4

func _enter_tree():
	bull.collision_shape.disabled = true
	
func _exit_tree():
	bull.collision_shape.disabled = false
	
func _ready():
	bull.animation_player.play("idle")
	bull.velocity = bull.global_position.direction_to(bull.gate_marker.global_position) * bull.approach_speed
	
func _physics_process(_delta: float):
	if bull.global_position.distance_to(bull.gate_marker.global_position) <= BULL_DISTANCE_THRESHOLD:
		_on_gate_marker_reached()
	else:
		bull.move_and_slide()
		
func _on_gate_marker_reached():
	if bull.meta.tutorial_enabled:
		state_transition_requested.emit(Bull.State.IDLE)
	else:
		bull.start_moving()
