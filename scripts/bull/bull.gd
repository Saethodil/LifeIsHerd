extends CharacterBody2D

class_name Bull

enum State { 
	IDLE,
	ENTER,
	APPROACH,
	GRAZE,
	EAT,
	RECOVERY,
	ANGRY,
	CHARGE,
	BUMP,
	STAB,
	SWIPE,
	STOMP,
	SPIN,
	EXIT,
	BOW
}

signal state_changed(new_state: State)
signal player_body_entered(player: Matador)
signal shake_requested(strength: ScreenShake.ShakeStrength)
signal sound_requested(sound_effect: GameAudioPlayer.SoundEffect)
signal parry_tooltip_requested
signal health_depleted

@onready var step_particles: StepParticles = $StepParticles
@onready var sprite: Sprite2D = $Sprite2D
@onready var player_spin_hitbox: Area2D = $PlayerSpinHitbox
@onready var player_spin_hitbox_collision_shape: CollisionShape2D = $PlayerSpinHitbox/CollisionShape2D
@onready var player_hitbox: Area2D = $PlayerHitbox
@onready var player_hitbox_collision_shape: CollisionShape2D = $PlayerHitbox/CollisionShape2D
@onready var charge_area: Area2D = $ChargeArea
@onready var charge_area_collision_shape: CollisionShape2D = $ChargeArea/CollisionShape2D
@onready var collision_shape: CollisionShape2D = $CollisionShape2D
@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var swipe_spawn_rotate_anchor: Node2D = $SwipeSpawnRotateAnchor
@onready var swipe_spawn_marker: Node2D = $SwipeSpawnRotateAnchor/Marker2D

@export var initial_face_direction: Vector2 = Vector2.ZERO
@export var charge_count: int = 1
@export var charge_inter_delay: float = 0.5
@export var charge_speed: float = 300
@export var spin_speed: float = 150
@export var graze_speed: float = 60
@export var approach_speed: float = 45
@export var stomp_markers: Array[BullStompMarker] = []
@export var exit_marker: Node2D
@export var graze_center: Vector2
@export var graze_radius: float
@export var gate_marker: Node2D
@export var follow_node: Node2D
@export var angry_time: float = 1
@export var max_health: float = 100.0
@export var max_frustration: float = 100.0

var meta: BullMeta
var has_attacked = false
var has_moved = false
var has_charged = false
var current_state: BullState
var current_health: float = max_health
var current_frustration: float = 0.0
var state_factory: BullStateFactory = BullStateFactory.new()

var _movement_time_scale: float = 1.0
var movement_time_scale: float:
	get():
		return _movement_time_scale
	set(value):
		_movement_time_scale = value
		animation_player.speed_scale = _movement_time_scale
		
var health_percentage: float:
	get():
		return current_health / max_health
		
func _ready():
	switch_state(State.IDLE)
	switch_look_direction(initial_face_direction)
	
func _physics_process(_delta: float):
	if velocity * movement_time_scale == Vector2.ZERO:
		step_particles.stop_emitting()
	else:
		step_particles.start_emitting(velocity.normalized(), 1, StepParticles.DUST_SIZE.BULL)

func update_meta(bull_meta: BullMeta):
	meta = bull_meta
	charge_count = bull_meta.charge_count
	charge_speed = bull_meta.charge_speed
	angry_time = bull_meta.angry_delay
	approach_speed = bull_meta.approach_speed
	sprite.texture = meta.sprite_sheet
	max_health = bull_meta.max_health
	current_health = max_health

func start_moving():
	switch_state(meta.first_movement if !has_moved else _get_random_movement_state())
	has_moved = true
	
func move_and_slide_with_time_scale() -> bool:
	var old_velocity = velocity
	velocity *= movement_time_scale
	var result = move_and_slide()
	velocity = old_velocity
	return result
	
func switch_state(state: State):
	var state_args: Dictionary[String, Variant] = {}
	if state == State.APPROACH:
		var next_state = meta.first_attack if !has_attacked else _get_random_attack_state()
		if next_state == Bull.State.STOMP:
			state_args["attack_distance_threshold"] = 8
		state_args["attack_state"] = next_state
		var approach_node: Node2D
		if next_state == Bull.State.STOMP:
			approach_node = _get_closest_stomp_marker() if !(current_state is BullStompState) else stomp_markers.pick_random()
		else:
			approach_node = follow_node
		has_attacked = true
		state_args["approach_node"] = approach_node
	if current_state is BullChargeState:
		has_charged = true
		if state == State.BUMP:
			state_args["bump_direction"] = (current_state as BullChargeState).charge_direction * -1
	if current_state is BullApproachState && state == State.STOMP:
		state_args["stomp_direction"] = current_state.approach_node.stomp_direction
	if !(current_state is BullBumpState) && state == State.ANGRY:
		state_args["remaining_charges"] = charge_count
	if current_state && current_state.get("remaining_charges"):
		state_args["remaining_charges"] = current_state.remaining_charges
	if current_state != null:
		current_state.queue_free()

	current_state = state_factory.get_state(state, state_args)
	current_state.setup(self)
	current_state.state_transition_requested.connect(switch_state)
	state_changed.emit(state)
	call_deferred("add_child", current_state)

func _get_random_movement_state() -> Bull.State:
	return meta.available_movements.pick_random()
	
func _get_random_attack_state() -> Bull.State:
	return meta.available_attacks.pick_random()
	
func _get_closest_stomp_marker() -> BullStompMarker:
	var min_distance = stomp_markers[0].global_position.distance_to(global_position)
	var result = stomp_markers[0]
	for stomp_marker in stomp_markers.slice(1):
		var stomp_distance = stomp_marker.global_position.distance_to(global_position)
		if stomp_distance < min_distance:
			result = stomp_marker
			min_distance = stomp_distance
	return result
	
func switch_look_direction(direction: Vector2):
	var direction_angle = deg_to_rad(round(rad_to_deg(direction.angle()) / 45.0) * 45.0)
	player_hitbox.rotation = direction_angle
	charge_area.rotation = direction_angle
	sprite.rotation = direction_angle
	collision_shape.rotation = direction_angle
	
func reset_frustration():
	current_frustration = 0.0
	
func frustrate(amount: float):
	if (
		current_state is BullAngryState ||
		current_state is BullChargeState ||
		current_state is BullBumpState ||
		current_state is BullRecoveryState ||
		current_state is BullExitState ||
		current_state is BullBowState
	):
		return
		
	current_frustration = max(0, min(current_frustration + amount, max_frustration))
	if current_frustration == max_frustration:
		switch_state(State.ANGRY)
	
func drain(amount: float):
	current_health = max(current_health - amount, 0.0)
	if current_health <= 0:
		health_depleted.emit()
		
func request_sound(sound_effect: GameAudioPlayer.SoundEffect):
	sound_requested.emit(sound_effect)
	
func request_shake(strength: ScreenShake.ShakeStrength):
	shake_requested.emit(strength)
	
func request_parry_tooltip():
	parry_tooltip_requested.emit()

func _on_player_hitbox_body_entered(body: Node2D) -> void:
	player_body_entered.emit(body as Matador)

func _on_player_spin_hitbox_body_entered(body: Node2D) -> void:
	player_body_entered.emit(body as Matador)
