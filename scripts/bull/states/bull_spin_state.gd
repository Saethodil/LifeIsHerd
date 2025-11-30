extends BullState

class_name BullSpinState

const SPIN_TIME = 3.0
const SPIN_BOUNCE_WAIT_TIME = 1

var is_spinning = false
var spin_direction = Vector2.ZERO
var time_since_last_bounce_update_tick: int = 0
	
func _enter_tree():
	bull.player_hitbox_collision_shape.disabled = true
	bull.player_spin_hitbox_collision_shape.disabled = false

func _ready():
	bull.player_body_entered.connect(_on_player_body_entered)
	bull.animation_player.play("spin_start")
	await bull.animation_player.animation_finished
	bull.animation_player.play("spin_loop")
	is_spinning = true
	spin_direction = bull.global_position.direction_to(bull.follow_node.global_position)
	await get_tree().create_timer(SPIN_TIME).timeout
	_stop_spinning()

func _physics_process(_delta: float):
	bull.velocity = spin_direction * bull.spin_speed
	
	var has_collided = bull.move_and_slide()
	if has_collided:
		var current_tick = Time.get_ticks_msec()
		if current_tick - time_since_last_bounce_update_tick > SPIN_BOUNCE_WAIT_TIME * 1000:
			time_since_last_bounce_update_tick = current_tick
			spin_direction = spin_direction.bounce(bull.global_position.direction_to(_get_viewport_center()))

func _get_viewport_center() -> Vector2:
	return get_viewport().get_visible_rect().get_center()

func _on_player_body_entered(player: Matador):
	player.hurt(spin_direction)
	if bull.current_state == self:
		_stop_spinning()
		
func _stop_spinning():
	if !is_spinning: 
		return

	bull.animation_player.play("spin_end")
	spin_direction = Vector2.ZERO
	is_spinning = false
	await bull.animation_player.animation_finished
	bull.animation_player.play("RESET")
	bull.player_hitbox_collision_shape.disabled = false
	bull.player_spin_hitbox_collision_shape.disabled = true
	await bull.animation_player.animation_finished
	bull.start_moving()
