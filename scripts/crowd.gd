extends Node2D

class_name Crowd

@onready var health_pickup: Node2D = $HealthPickup
@onready var patron_container: Node2D = $PatronContainer
@onready var rose_container: Node2D = $RoseContainer

const PATRON_SCENE: PackedScene = preload("res://scenes/patron.tscn")
const ROSE_SCENE: PackedScene = preload("res://scenes/rose.tscn")
const PLACEHOLDER_ASSET = preload("res://assets/sprites/dust-particle.png")
const CROWD_ASSETS: Array[Texture2D] = [
	preload("res://assets/sprites/crowd1.png"),
	preload("res://assets/sprites/crowd2.png"),
	preload("res://assets/sprites/crowd3.png")
]
const ORIGIN = Vector2(128, 128)
const CROWD_SIZE = 100
const ROSE_SIZE = 20
const ARENA_RADIUS = 103
const DISTANCE_RANGE: Array[int] = [130, 130, 130, 130, 148, 148, 165]	#static/measured distances/radius from origin to seating. Repeated values to tilt more patron spawns at closer seating.
const ANGLE_RANGE: Array[Vector2] = [
	Vector2(PI/4+PI/16, 5*PI/4-PI/16),
	Vector2(-3*PI/4+PI/16, PI/4-PI/16)
]
const CELEBRATE_DELAY_MIN = 0.0
const CELEBRATE_DELAY_MAX = 0.3
const ROSE_THROW_INTERITEM_DELAY_MIN = 0.1
const ROSE_THROW_INTERITEM_DELAY_MAX = 0.2
const ROSE_DISTANCE_MIN = 64.0
const ROSE_DISTANCE_MAX = 68.0

func _ready() -> void:
	create_crowd()	
	
func celebrate() -> void:
	for child in patron_container.get_children():
		(child as Patron).final_celebration(
			randf_range(CELEBRATE_DELAY_MIN, CELEBRATE_DELAY_MAX)
		)
		
func throw_roses():
	var patrons = patron_container.get_children()
	for index in range(0, ROSE_SIZE):
		var patron_index = randi_range(0, patrons.size() - 1)
		var patron = patrons[patron_index]
		patrons.remove_at(patron_index)
		throw_rose(patron)
		await get_tree().create_timer(randf_range(ROSE_THROW_INTERITEM_DELAY_MIN, ROSE_THROW_INTERITEM_DELAY_MAX)).timeout
	
func throw_rose(patron: Patron):
	var rose = ROSE_SCENE.instantiate() as Rose
	rose.global_position = patron.global_position
	rose.flip_h = randi_range(0, 1) != 0
	var end_position = rose.global_position + rose.global_position.direction_to(ORIGIN) * randf_range(ROSE_DISTANCE_MAX, ROSE_DISTANCE_MAX)
	
	rose_container.add_child(rose)
	
	var tween = get_tree().create_tween()
	tween.set_ease(Tween.EASE_IN_OUT)
	tween.tween_property(
		rose, 
		"global_position", 
		end_position, 
		0.5
	)
	
func create_crowd() -> void:
	# for each member of the crowd
	for i in CROWD_SIZE:
		#create a patron
		var patron = PATRON_SCENE.instantiate()
		
		# alternate which section the patron will sit in
		var section = i % 2
		
		var distance = DISTANCE_RANGE[randi_range(0, DISTANCE_RANGE.size() - 1)]	# pick one of the distances
		var angle = randf_range(ANGLE_RANGE[section].x, ANGLE_RANGE[section].y)			# alternate which side of the seating the patron will sit on by selecting an angle within the range of seating
		var x = distance * sin(angle)													# find the x and y value of the patron based on radius and angle selected
		var y = distance * cos(angle)
		
		patron.position = Vector2(x, y) + ORIGIN		# place patron in correct position
		
		var asset_index = randi_range(0, CROWD_ASSETS.size() - 1)	# select one of the patron textures randomly
		patron.asset_texture = CROWD_ASSETS[asset_index]
		
		patron_container.add_child(patron)
	
func crowd_wave() -> void:
	var tween = create_tween()
	tween.tween_property($Area2D, "rotation", 4*PI, 3)

func _on_health_pickup_start_spawn() -> void:
	if health_pickup.is_health_spawned:
		return
	else:
		var starting_distance = DISTANCE_RANGE.pick_random()
		var section = randi_range(0,1)
		var starting_angle = randf_range(ANGLE_RANGE[section].x, ANGLE_RANGE[section].y)
		var starting_point = Vector2(starting_distance * sin(starting_angle), starting_distance * cos(starting_angle)) + ORIGIN
		
		var landing_distance = randf_range(0, ARENA_RADIUS)
		var landing_angle = randf_range(0,2*PI)
		var ending_point = Vector2(landing_distance * sin(landing_angle), landing_distance * cos(landing_angle)) + ORIGIN
		
		health_pickup.position = starting_point
		health_pickup.visible = true

		await get_tree().create_timer(1.0).timeout
		
		var tween = get_tree().create_tween()
		tween.tween_property(health_pickup,"global_position", ending_point,1.5)
		health_pickup.animation_player.play("flying")

#TODO: Reset the position of the pickup to be off-screen after it is picked up
func _on_health_pickup_picked_up() -> void:
	health_pickup.position = Vector2(0,0)
	health_pickup.visible = false
