extends Node2D

class_name Patron

@onready var sprite: Sprite2D = $Area2D/Sprite2D
@onready var celebration_timer: Timer = $CelebrationTimer
@onready var animation_player: AnimationPlayer = $AnimationPlayer

var asset_texture: Texture2D

func _ready():
	sprite.texture = asset_texture

func set_timer():
	var rng = RandomNumberGenerator.new()
	
	var wait_time = rng.randf_range(5, 25)
	celebration_timer.wait_time = wait_time
	
	celebration_timer.start()

func _on_celebration_timer_timeout() -> void:
	animation_player.play("celebrate")
	set_timer()

func final_celebration(delay: float = 0.0) -> void:
	celebration_timer.stop()
	if delay > 0:
		await get_tree().create_timer(delay).timeout
	animation_player.play("final_celebration")
	await animation_player.animation_finished
	set_timer()

func _on_area_2d_area_entered(_area: Area2D) -> void:
	animation_player.play("celebrate_wave")
	set_timer()
	
