extends BullState

class_name BullStompState

var stomp_direction: Vector2 = Vector2.ZERO

const STOMP_AREA_SCENE = preload("res://scenes/bull_stomp_area.tscn")

func _enter_tree():
	bull.velocity = Vector2.ZERO
	
func _ready():
	bull.switch_look_direction(stomp_direction)
	bull.animation_player.play("stomp")
	await bull.animation_player.animation_finished
	_spawn_area()
	
func _spawn_area():
	var stomp_area = STOMP_AREA_SCENE.instantiate() as BullStompArea
	var angle = stomp_direction.angle()
	stomp_area.direction = stomp_direction
	bull.start_moving()
	bull.swipe_spawn_rotate_anchor.rotation = angle
	bull.get_parent().add_child(stomp_area)
	bull.request_shake(ScreenShake.ShakeStrength.SMALL)
	bull.request_sound(GameAudioPlayer.SoundEffect.STOMP_EFFECT)
	stomp_area.global_position = bull.swipe_spawn_marker.global_position
