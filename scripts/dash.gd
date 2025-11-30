extends Node2D

signal dash_ended

@onready var dash_timer: Timer = $DashTimer
@onready var cooldown_timer: Timer = $CooldownTimer
@onready var cooldown_sprite: Sprite2D = $CooldownSprite
@onready var animation_player: AnimationPlayer = $CooldownSprite/AnimationPlayer

const COOLDOWN_ANIMATION_KEY = "cooldown"

var dash_input:Vector2 = Vector2.ZERO

func can_dash() -> bool:
	return cooldown_timer.is_stopped()

func is_dashing() -> bool:
	return !dash_timer.is_stopped()

func start_dash(input:Vector2):
	if can_dash():
		dash_input = input*3
		dash_timer.start()
		cooldown_timer.start()


func _on_cooldown_timer_timeout() -> void:
	cooldown_sprite.frame = 0
	cooldown_sprite.visible = true
	animation_player.play(COOLDOWN_ANIMATION_KEY)


func _on_animation_player_animation_finished(anim_name: StringName) -> void:
	if anim_name == COOLDOWN_ANIMATION_KEY: 
		cooldown_sprite.visible = false

func _on_dash_timer_timeout() -> void:
	dash_ended.emit()
