class_name StepParticles
extends GPUParticles2D

enum DUST_SIZE { MATADOR = 1, BULL = 2 }

func start_emitting(direction: Vector2, speed_scale: float, size: float = DUST_SIZE.MATADOR):
	process_material.set("scale", Vector2(size/2,size/2))
	process_material.direction = Vector3(-direction.x,-direction.y,0)
	speed_scale = speed_scale
	emitting = true
	
func stop_emitting():
	emitting = false
