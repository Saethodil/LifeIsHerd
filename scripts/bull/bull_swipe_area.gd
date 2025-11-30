extends Area2D

class_name BullSwipeArea

@export var swipe_direction: Vector2 = Vector2.ZERO

@onready var animation_player: AnimationPlayer = $AnimationPlayer

var has_hit = false

func _ready():
	animation_player.play("swipe")
	await animation_player.animation_finished
	queue_free()

func _on_body_entered(player: Matador):
	if has_hit: return
	has_hit = true
	player.hurt(swipe_direction, 0.5)
