class_name BullStompArea

extends CharacterBody2D

@onready var animation_player: AnimationPlayer = $AnimationPlayer

@export var direction: Vector2 = Vector2.RIGHT

const SPEED = 120

var has_hit = false

func _ready():
	animation_player.play("default")
	velocity = direction.normalized() * SPEED
	rotation = direction.angle()
	await animation_player.animation_finished
	queue_free()
	
func _physics_process(_delta: float):
	move_and_slide()

func _on_body_entered(player: Matador):
	if has_hit: return
	
	has_hit = true
	player.hurt(direction, 0.5)
