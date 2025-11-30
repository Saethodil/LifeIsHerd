extends Node2D

class_name Rose

@export var flip_h: bool = false

@onready var sprite: Sprite2D = $Sprite2D

func _ready():
	sprite.flip_h = flip_h
