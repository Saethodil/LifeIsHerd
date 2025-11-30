extends Node2D

class_name Confetti

signal finished

@onready var green: GPUParticles2D = $Green
@onready var blue: GPUParticles2D = $Blue
@onready var red: GPUParticles2D = $Red

func start():
	for particles in [green, blue, red]:
		particles.emitting = true


func _on_confetti_particle_finished() -> void:
	finished.emit()
	queue_free()
