extends BullState

class_name BullExitState

const BULL_DISTANCE_THRESHOLD = 4

func _enter_tree():
	bull.collision_shape.disabled = true
	
func _exit_tree():
	bull.collision_shape.disabled = false
	
func _ready():
	bull.animation_player.play("walk")
	bull.velocity = bull.global_position.direction_to(bull.exit_marker.global_position) * bull.approach_speed
	bull.switch_look_direction(bull.velocity.normalized())
	
func _physics_process(_delta: float):
	if bull.global_position.distance_to(bull.exit_marker.global_position) <= BULL_DISTANCE_THRESHOLD:
		bull.switch_look_direction(Vector2.DOWN)
		state_transition_requested.emit(Bull.State.BOW)
	else:
		bull.move_and_slide()
