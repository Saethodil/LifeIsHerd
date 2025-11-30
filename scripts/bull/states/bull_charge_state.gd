extends BullState

class_name BullChargeState

var charge_direction = Vector2.ZERO
var remaining_charges: int = 1

const WORLD_COLLISION_DRAIN_AMOUNT = 25

var pending_hurt = false
var has_missed = false

func _enter_tree():
	bull.charge_area_collision_shape.disabled = false
	
func _exit_tree():
	bull.charge_area_collision_shape.disabled = true
	
func _ready():
	bull.request_sound(GameAudioPlayer.SoundEffect.CHARGE)
	bull.animation_player.play("charge")
	bull.charge_area.body_entered.connect(_on_player_body_entered)
	_seek()
	
func _seek():
	charge_direction = bull.global_position.direction_to(bull.follow_node.global_position)
	bull.velocity = bull.charge_speed * charge_direction
	bull.switch_look_direction(bull.velocity.normalized())
	
func _physics_process(_delta: float):
	if bull.meta.charge_heat_seek && !has_missed:
		_seek()

	var has_collided = bull.move_and_slide_with_time_scale()
	if has_collided:
		if pending_hurt && !bull.follow_node.is_parrying:
			remaining_charges = 0
			bull.follow_node.hurt(charge_direction)
		else:
			remaining_charges -= 1
			bull.request_shake(ScreenShake.ShakeStrength.MEDIUM)
			bull.drain(WORLD_COLLISION_DRAIN_AMOUNT)
		
		if bull.current_state == self:
			state_transition_requested.emit(Bull.State.BUMP)
		
func _on_player_body_entered(player: Matador):
	if player.is_parrying: 
		has_missed = true
		return
	
	if bull.meta.tutorial_enabled && !bull.has_charged:
		bull.movement_time_scale = 0.0
		bull.request_parry_tooltip()
		return
	
	remaining_charges = 0
	player.hurt(charge_direction)
	if bull.current_state == self:
		state_transition_requested.emit(Bull.State.BUMP)
