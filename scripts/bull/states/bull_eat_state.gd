extends BullState

class_name BullEatState

const EAT_TIME = 2.0
	
func _ready():
	bull.velocity = Vector2.ZERO
	bull.switch_look_direction(Vector2.DOWN)
	bull.animation_player.play("idle")
	await get_tree().create_timer(EAT_TIME).timeout
	state_transition_requested.emit(Bull.State.GRAZE)
