extends Node

var _data: Dictionary = {}

var DIFFICULTY_UNLOCKED_KEYS: Array[String] = [
	DATA_KEY_BULL_EASY,
	DATA_KEY_BULL_NORMAL,
	DATA_KEY_BULL_HARD,
]

var DIFFICULTY_BEATEN_KEYS: Array[String] = [
	DATA_KEY_BULL_BEATEN_EASY,
	DATA_KEY_BULL_BEATEN_NORMAL,
	DATA_KEY_BULL_BEATEN_HARD,
]

const DATA_KEY_BULL_EASY = "bull_level_easy"
const DATA_KEY_BULL_NORMAL = "bull_level_normal"
const DATA_KEY_BULL_HARD = "bull_level_hard"
const DATA_KEY_BULL_BEATEN_EASY = "bull_beaten_easy"
const DATA_KEY_BULL_BEATEN_NORMAL = "bull_beaten_normal"
const DATA_KEY_BULL_BEATEN_HARD = "bull_beaten_hard"

const DATA_KEY_SCREEN_SHAKE = "screen_shake"

const DATA_VALUE_BULL_BEATEN = 1
const DATA_VALUE_BULL_BEATEN_FLAWLESS = 2

func reset():
	_data = {}
	
func increment_data_value(key: String, offset):
	var current_value = 0 if !has_data_value(key) else _data[key]
	_data[key] = current_value + offset
	
func set_data_value(key: String, value):
	_data[key] = value
	
func has_data_value(key: String):
	return _data.has(key)
	
func get_data_value(key: String):
	if !has_data_value(key):
		return null
	return _data[key]
