class_name ScreenShake

extends Camera2D


const SHAKE_DECAY_RATE: float = 5.0
enum ShakeStrength { SMALL = 2, MEDIUM = 4, LARGE = 8 }

var _shake_strength: float = 0.0

func shake_screen(strength: ShakeStrength) -> void:
	if !GameState.has_data_value(GameState.DATA_KEY_SCREEN_SHAKE) || GameState.get_data_value(GameState.DATA_KEY_SCREEN_SHAKE) == true:
		_shake_strength = strength

func _process(delta: float) -> void:
	_shake_strength = lerp(_shake_strength, 0.0, SHAKE_DECAY_RATE * delta)
	offset = _get_random_offset()

func _get_random_offset() -> Vector2:
	var rand = RandomNumberGenerator.new()
	
	return Vector2(
		rand.randf_range(-_shake_strength, _shake_strength),
		rand.randf_range(-_shake_strength, _shake_strength)
	)
