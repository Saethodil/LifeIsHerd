extends BullState

class_name BullAngryState

var remaining_charges: int = 0
	
func _ready():
	bull.request_sound(GameAudioPlayer.SoundEffect.GROWL)
	bull.animation_player.play("charge")
	await get_tree().create_timer(bull.angry_time).timeout
	state_transition_requested.emit(Bull.State.CHARGE)

func _physics_process(_delta: float):
	var look_direction = bull.global_position.direction_to(bull.follow_node.global_position)
	bull.switch_look_direction(look_direction)
