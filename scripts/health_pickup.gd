extends Node2D

@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var spawn_timer: Timer = $SpawnTimer

signal start_spawn
signal picked_up

var is_health_spawned: bool = false

func initiate_health() -> void:
	if !spawn_timer.is_stopped():
		spawn_timer.stop()
	spawn_timer.wait_time = randi_range(25,40)
	spawn_timer.start()

func _on_spawn_timer_timeout() -> void:
	if is_health_spawned:
		initiate_health()
	else:
		start_spawn.emit()
		is_health_spawned = true

func _on_area_2d_body_entered(_body: Node2D) -> void:
	if !is_health_spawned: return
	is_health_spawned = false
	picked_up.emit()
	initiate_health()

func stop_health_spawn() -> void:
	spawn_timer.stop()
	hide()
