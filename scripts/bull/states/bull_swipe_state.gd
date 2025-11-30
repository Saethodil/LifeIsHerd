extends BullState

class_name BullSwipeState

const SWIPE_TIME_DELAY = 0.5
const ANIMATION_TIME = 0.9

var swipe_direction: Vector2 = Vector2.ZERO

const SWIPE_AREA_SCENE = preload("res://scenes/bull_swipe_area.tscn")

func _enter_tree():
	bull.velocity = Vector2.ZERO
	
func _ready():
	bull.animation_player.play("head_swipe")
	swipe_direction = bull.global_position.direction_to(bull.follow_node.global_position)
	bull.switch_look_direction(swipe_direction)
	await get_tree().create_timer(SWIPE_TIME_DELAY).timeout
	_swipe()
	await get_tree().create_timer(ANIMATION_TIME - SWIPE_TIME_DELAY).timeout
	bull.start_moving()

func _swipe():
	bull.request_sound(GameAudioPlayer.SoundEffect.SLASH)
	var swipe_area = SWIPE_AREA_SCENE.instantiate() as BullSwipeArea
	var angle = swipe_direction.angle()
	swipe_area.swipe_direction = swipe_direction
	swipe_area.rotation = angle
	bull.swipe_spawn_rotate_anchor.rotation = angle
	bull.get_parent().add_child(swipe_area)
	swipe_area.global_position = bull.swipe_spawn_marker.global_position
	
