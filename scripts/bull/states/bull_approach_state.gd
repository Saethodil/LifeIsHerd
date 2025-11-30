extends BullState

class_name BullApproachState

var time_since_last_steering_update_tick: int
var time_since_start: int

const STEERING_UPDATE_TICK_FREQUENCY = 200
const APPROACH_WEIGHT_DISTANT = 1.0
const APPROACH_WEIGHT_CLOSE = 0.4
const DISTANCE_THRESHOLD_OUTER = 32
const DISTANCE_THRESHOLD_INNER = 24

var approach_node: Node2D
var attack_state: Bull.State
var attack_distance_threshold: float = 32

func _ready():
	time_since_start = Time.get_ticks_msec()
	bull.animation_player.play("walk")
	time_since_last_steering_update_tick = Time.get_ticks_msec()
	
func _physics_process(_delta: float):
	if bull.global_position.distance_to(approach_node.global_position) <= attack_distance_threshold:
		state_transition_requested.emit(attack_state)
		return
		
	var current_tick = Time.get_ticks_msec()
	
	if bull.meta.approach_max_time > 0 && current_tick - time_since_start > bull.meta.approach_max_time * 1000:
		state_transition_requested.emit(Bull.State.RECOVERY)
		return
	
	if current_tick - time_since_last_steering_update_tick > STEERING_UPDATE_TICK_FREQUENCY:
		time_since_last_steering_update_tick = current_tick
		_update_steering()
		
	bull.move_and_slide()
	
func _update_steering():
	bull.velocity = _get_steering_force() * bull.approach_speed
	bull.switch_look_direction(bull.velocity)
	
func _get_steering_force() -> Vector2:
	var direction = bull.global_position.direction_to(approach_node.global_position)
	var weight = _get_approach_weight()
	return direction * weight

func _get_approach_weight() -> float:
	var distance = bull.global_position.distance_to(approach_node.global_position)
	if distance > DISTANCE_THRESHOLD_OUTER:
		return APPROACH_WEIGHT_DISTANT
	elif distance < DISTANCE_THRESHOLD_INNER:
		return APPROACH_WEIGHT_CLOSE
	else:
		var distance_to_inner = distance - DISTANCE_THRESHOLD_INNER
		var close_range_distance = DISTANCE_THRESHOLD_OUTER - DISTANCE_THRESHOLD_INNER
		return lerpf(
			APPROACH_WEIGHT_CLOSE, 
			APPROACH_WEIGHT_DISTANT, 
			distance_to_inner / close_range_distance
		) 
