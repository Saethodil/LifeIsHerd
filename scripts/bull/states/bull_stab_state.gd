extends BullState

class_name BullStabState

const STAB_TIME_DELAY = 0.5
const STAB_TIME = 0.25
const ANIMATION_TIME = 0.9

var stab_direction: Vector2 = Vector2.ZERO
var has_hit = false

func _enter_tree():
	bull.velocity = Vector2.ZERO
	
func _ready():
	bull.animation_player.play("head_swipe_reverse")
	stab_direction = bull.global_position.direction_to(bull.follow_node.global_position)
	await get_tree().create_timer(STAB_TIME_DELAY).timeout
	await _slash()
	bull.start_moving()
	
func _physics_process(_delta: float):
	bull.move_and_slide()
	if bull.player_hitbox.has_overlapping_bodies() && bull.velocity != Vector2.ZERO && !has_hit:
		has_hit = true
		bull.follow_node.hurt(stab_direction)

func _slash():
	bull.request_sound(GameAudioPlayer.SoundEffect.SLASH)
	bull.velocity = bull.charge_speed * stab_direction
	var tween = create_tween()
	tween.tween_property(bull, "velocity", Vector2.ZERO, STAB_TIME)
	await tween.finished
	await get_tree().create_timer(ANIMATION_TIME - STAB_TIME - STAB_TIME_DELAY).timeout
