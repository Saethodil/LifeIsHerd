extends BullState

class_name BullGrazeState

const GRAZE_DISTANCE = 64.0
const GRAZE_APPROACH_THRESHOLD = 4.0

var graze_position: Vector2

func _enter_tree():
	graze_position = _get_next_graze_position()
	bull.switch_look_direction(bull.global_position.direction_to(graze_position))
	bull.velocity = bull.global_position.direction_to(graze_position) * bull.graze_speed

func _ready():
	bull.animation_player.play("walk")
	
func _physics_process(_delta: float):
	bull.move_and_slide()
	if bull.global_position.distance_to(graze_position) < GRAZE_APPROACH_THRESHOLD:
		state_transition_requested.emit(Bull.State.EAT)
	
func _get_next_graze_position() -> Vector2:
	var target_position = bull.global_position + _get_random_direction() * GRAZE_DISTANCE
	var distance_from_graze_center = target_position.distance_to(bull.graze_center)
	if distance_from_graze_center > bull.graze_radius:
		target_position = bull.graze_center + (bull.graze_center.direction_to(target_position) * (distance_from_graze_center - bull.graze_radius))
	return target_position
	
func _get_random_direction() -> Vector2:
	return Vector2(randf_range(-1, 1), randf_range(-1, 1)).normalized()
