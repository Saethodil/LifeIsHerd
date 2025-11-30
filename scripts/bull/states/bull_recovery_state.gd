extends BullState

class_name BullRecoveryState

const RECOVERY_TIME = 1.0

var remaining_charges: int = 0

func _ready() -> void:
	bull.velocity = Vector2.ZERO
	bull.animation_player.play("idle")
	await get_tree().create_timer(RECOVERY_TIME).timeout
	
	if remaining_charges > 0:
		state_transition_requested.emit(Bull.State.ANGRY)
	else:
		bull.reset_frustration()
		bull.start_moving()
