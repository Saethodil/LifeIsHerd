extends BullState

class_name BullBumpState

const BUMP_TIME = 0.1

var bump_direction: Vector2 = Vector2.ZERO
var remaining_charges: int = 0
	
func _ready():
	bull.animation_player.play("charge")
	await _bump()
	state_transition_requested.emit(Bull.State.RECOVERY)
	
func _physics_process(_delta: float):
	bull.move_and_slide()
	
func _bump():
	bull.velocity = bull.charge_speed * bump_direction
	bull.request_sound(GameAudioPlayer.SoundEffect.STOMP)
	var tween = create_tween()
	tween.tween_property(bull, "velocity", Vector2.ZERO, BUMP_TIME)
	await tween.finished
