class_name ParticlePreloader
extends CanvasLayer

signal completed

@onready var render_container: Node2D = $RenderContainer
@onready var render_timer: Timer = $RenderTimer

const STEP_PARTICLES = preload("res://scenes/particles/step_particles.tscn")
const CONFETTI_PARTICLES = preload("res://scenes/particles/confetti_particles.tscn")
const DUST_PARTICLES = preload("res://scenes/particles/dust_particles.tscn")

var all_particle_scenes: Array[PackedScene]:
	get():
		return [
			STEP_PARTICLES,
			CONFETTI_PARTICLES,
			DUST_PARTICLES
		]
		
var remaining_particle_scenes: Array[PackedScene]
var current_particle: Node2D

func _ready():
	remaining_particle_scenes = all_particle_scenes
	_load_next()

func _load_next():
	if current_particle && is_instance_valid(current_particle):
		current_particle.queue_free()
	if remaining_particle_scenes.is_empty():
		_on_complete()
	else:
		current_particle = remaining_particle_scenes.pop_back().instantiate()
		if current_particle is GPUParticles2D:
			current_particle.emitting = true
		render_container.add_child(current_particle)
		render_timer.start()

func _on_complete():
	completed.emit()
	queue_free()

func _on_render_timer_timeout():
	_load_next()
