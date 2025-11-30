class_name Matador
extends CharacterBody2D

signal dash_started
signal hurt_started
signal wave_started
signal wave_ended
signal approach_marker_reached
signal sound_requested(sound_effect: GameAudioPlayer.SoundEffect)
signal shake_requested(sound_effect: ScreenShake.ShakeStrength)
signal parry_started
signal parry_ended
signal health_depleted

@export var is_input_enabled = true
@export var is_dash_input_enabled = true
@export var is_wave_input_enabled = true
@export var initial_face_direction: Vector2 = Vector2(-1, -1)
@export var approach_marker: Node2D = null

@onready var parry_area: Area2D = $ParryArea
@onready var parry_buffer_timer: Timer = $ParryBufferTimer
@onready var parry_delay_timer: Timer = $ParryDelayTimer
@onready var animation_player:AnimationPlayer = $Sprite2D/AnimationPlayer
@onready var sprite:Sprite2D = $Sprite2D
@onready var dust_particles: StepParticles = $StepParticles
@onready var collision_shape: CollisionShape2D = $CollisionShape2D
@onready var dash = $Dash
@onready var stamina_bar: StaminaBar = %StaminaBar

var is_parrying = false
var is_bumping = false
@onready var is_waving = false

const max_speed: int = 80
const acceleration: int = 8
const friction: int = 6
const parry_speed: float = 160

const bump_speed: int = 200
const bump_time: float = 0.5
const bull_layer_number = 3

const approach_marker_distance_threshold: float = 4.0

func _ready():
	face(initial_face_direction)

func _physics_process(delta: float) -> void:
	if is_bumping || is_parrying:
		velocity = lerp(velocity, Vector2.ZERO, delta * friction) 
		move_and_slide()
		return
		
	var move_direction = Vector2.ZERO
	
	if is_input_enabled:
		move_direction = Vector2(
			Input.get_action_strength("ui_right") - Input.get_action_strength("ui_left"),
			Input.get_action_strength("ui_down") - Input.get_action_strength("ui_up")
		).normalized()
		
		if is_wave_input_enabled && Input.is_action_just_pressed("wave") && move_direction == Vector2.ZERO:
			_start_wave()
		elif Input.is_action_just_released("wave") || move_direction != Vector2.ZERO:
			end_wave()
	elif approach_marker:
		if global_position.distance_to(approach_marker.global_position) <= approach_marker_distance_threshold:
			approach_marker = null
			approach_marker_reached.emit()
			collision_shape.disabled = false
		else:
			collision_shape.disabled = true
			move_direction = global_position.direction_to(approach_marker.global_position)
		
	if is_waving:
		return
	
	if dash.is_dashing():
		move_direction = dash.dash_input
	
	if is_dash_input_enabled && Input.is_action_just_pressed("dash") && !dash.is_dashing() && move_direction != Vector2.ZERO && !stamina_bar.is_depleted:
		dash_started.emit()
		set_collision_mask_value(bull_layer_number, false)
		dash.start_dash(move_direction)
		animation_player.play("dash")
	elif Input.is_action_just_pressed("parry") && !is_parrying && parry_buffer_timer.time_left == 0 && parry_delay_timer.time_left == 0 && move_direction == Vector2.ZERO:
		parry_buffer_timer.start()
	elif parry_area.has_overlapping_areas() && parry_buffer_timer.time_left > 0 && !stamina_bar.is_depleted:
		_parry(global_position.direction_to(parry_area.get_overlapping_areas()[0].global_position).orthogonal())
		return
	elif move_direction && !dash.is_dashing():
		var speed_scale = (velocity/max_speed).distance_to(Vector2.ZERO) + 0.5

		if !dash.is_dashing():
			animation_player.play("walk")
			animation_player.speed_scale = speed_scale

		face(move_direction)
		
		dust_particles.start_emitting(move_direction, speed_scale)
	else:
		if !dash.is_dashing() && !is_parrying:
			animation_player.play("idle")
			animation_player.speed_scale = 0.75
		dust_particles.stop_emitting()
	
	var lerp_weight = delta * (acceleration if move_direction else friction)
	velocity = lerp(velocity, move_direction * max_speed, lerp_weight) 

	move_and_slide()
	
func hurt(direction: Vector2, strength: float = 1.0):
	if is_bumping:
		return
	
	hurt_started.emit()
		
	sound_requested.emit(GameAudioPlayer.SoundEffect.HURT)
	shake_requested.emit(ScreenShake.ShakeStrength.SMALL)
	
	if is_waving:
		end_wave()
		
	stamina_bar.hit()
	if !stamina_bar.is_depleted:
		await _bump(direction, strength)

func heal():
	stamina_bar.heal()
	sound_requested.emit(GameAudioPlayer.SoundEffect.EAT)
	
func face(direction: Vector2):
	sprite.rotation_degrees = 0
	sprite.rotate(direction.angle())
	
func _bump(direction: Vector2, strength: float):
	is_bumping = true
	is_input_enabled = false
	velocity = direction * bump_speed * strength
	await get_tree().create_timer(bump_time).timeout
	is_input_enabled = true
	is_bumping = false
	
func _parry(direction: Vector2):
	parry_started.emit()
	set_collision_mask_value(bull_layer_number, false)
	is_parrying = true
	is_input_enabled = false
	parry_buffer_timer.stop()
	animation_player.play("flourish")
	sound_requested.emit(GameAudioPlayer.SoundEffect.FLOURISH)
	velocity = direction * parry_speed
	await animation_player.animation_finished
	if approach_marker == null:
		is_input_enabled = true
	set_collision_mask_value(bull_layer_number, true)
	is_parrying = false
	parry_ended.emit()

func _on_stamina_bar_depleted():
	health_depleted.emit()

func _on_parry_buffer_timer_timeout():
	if is_parrying: return
	parry_delay_timer.start()

func _on_dash_ended():
	set_collision_mask_value(bull_layer_number, true)
	
func _start_wave():
	velocity = Vector2.ZERO
	animation_player.play("flag")
	animation_player.speed_scale = 1
	wave_started.emit()
	is_waving = true
	
func end_wave():
	wave_ended.emit()
	is_waving = false
