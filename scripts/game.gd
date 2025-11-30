extends Node2D

class_name Game

signal menu_requested
signal play_requested

@export var entrance_animated = false
@export var is_intro_music_enabled = true

@onready var entities_container: Node2D = $EntitiesContainer
@onready var confetti_container: Node2D = $EntitiesContainer/ConfettiContainer
@onready var audio_player: GameAudioPlayer = $GameAudioPlayer
@onready var tooltip: Tooltip = $Tooltip
@onready var matador: Matador = $EntitiesContainer/Matador
@onready var matador_gate_marker: Marker2D = $MatadorGateMarker
@onready var matador_exit_marker: Marker2D = $MatadorExitMarker
@onready var arena: Arena = $Arena
@onready var crowd: Crowd = $EntitiesContainer/Crowd
@onready var bull: Bull = $EntitiesContainer/Bull
@onready var bull_gate_marker: Marker2D = $BullGateMarker
@onready var bull_exit_marker: Marker2D = $BullExitMarker
@onready var bull_hud: BullHUD = $BullHUD
@onready var graze_region_center_marker: Marker2D = $GrazeRegion/CenterMarker
@onready var graze_region_radius_marker: Marker2D = $GrazeRegion/RadiusMarker
@onready var countdown: GameCountdown = $GameCountdown
@onready var screen_shake: ScreenShake = $ScreenShake
@onready var parry_focus_background: ColorRect = $EntitiesContainer/ParryFocusBackground

const CONFETTI_SCENE: PackedScene = preload("res://scenes/particles/confetti.tscn")
const GAME_WIN_SCENE: PackedScene = preload("res://scenes/game_win.tscn")
const GAME_LOSS_SCENE: PackedScene = preload("res://scenes/game_loss.tscn")
const INTRO_MUSIC_DELAY = 0.5
const WAVE_FRUSTRATION_AMOUNT = 50
const START_APPROACH_DELAY = 0.5
const COUNTDOWN_DELAY = 0.5
const BOW_DELAY = 0.5
const NEXT_TOOLTIP_DELAY = 0.5
const ENTITIES_HIDE_DURATION = 1.0
const ENTITIES_SHOW_DURATION = 1.0
const MENU_REQUEST_DELAY = 0.5

var confetti_timer: Timer
var has_lost = false
var is_flawless = true

var is_parry_focus_background_visible: bool:
	get():
		return parry_focus_background.modulate.a > 0

func start(bull_meta: BullMeta):
	bull.update_meta(bull_meta)
	bull.show()
	
	if bull_meta.tutorial_enabled:
		matador.is_dash_input_enabled = false
		matador.is_wave_input_enabled = false
		
	await audio_player.stop_background(START_APPROACH_DELAY)
	matador.approach_marker = matador_gate_marker
	bull.gate_marker = bull_gate_marker
	bull.exit_marker = bull_exit_marker

func _ready():
	var graze_radius = graze_region_center_marker.position.distance_to(graze_region_radius_marker.position)
	bull.graze_center = graze_region_center_marker.global_position
	bull.graze_radius = graze_radius
	bull.state_changed.connect(_on_bull_state_changed)
	_show_entities(entrance_animated)
	if is_intro_music_enabled:
		await get_tree().create_timer(INTRO_MUSIC_DELAY).timeout
		audio_player.play_background(GameAudioPlayer.BackgroundTrack.INTRO)

func _physics_process(delta: float):
	if matador.is_waving:
		bull.frustrate(delta * WAVE_FRUSTRATION_AMOUNT)
		matador.face(bull.position - matador.position)
	elif bull.meta:
		bull.frustrate(delta * bull.meta.frustration_decay_speed * -1)
	bull_hud.frustration_bar.value = bull.current_frustration
	bull_hud.update_energy_value(bull.health_percentage * 100)
	
func _on_bull_state_changed(new_state: Bull.State):
	if new_state == Bull.State.BUMP:
		crowd.celebrate()
	elif new_state == Bull.State.BOW && matador.approach_marker == null:
		_on_exit_marker_reached()

func _on_bull_health_depleted():
	bull.switch_state(Bull.State.EXIT)
	bull_hud.hide_animated()
	matador.end_wave()
	crowd.health_pickup.stop_health_spawn()
	audio_player.stop_background()
	matador.is_input_enabled = false
	matador.approach_marker = matador_exit_marker
	
func _on_matador_approach_marker_reached():
	if bull.health_percentage > 0:
		#await audio_player.play_sound(GameAudioPlayer.SoundEffect.ENTRANCE)
		countdown.start()
		crowd.crowd_wave()
	else:
		matador.face(Vector2.DOWN)
		if bull.current_state is BullBowState:
			_on_exit_marker_reached()

func _on_matador_health_depleted():
	bull.switch_state(Bull.State.EXIT)
	bull_hud.hide_animated()
	matador.is_input_enabled = false
	has_lost = true
	tooltip.hide_animated()
	crowd.health_pickup.stop_health_spawn()
	audio_player.stop_background(ENTITIES_HIDE_DURATION)
	await _hide_entities()
	audio_player.play_background(GameAudioPlayer.BackgroundTrack.TRY_AGAIN)
	_show_game_loss()
	
func _show_game_win():
	var game_win = GAME_WIN_SCENE.instantiate() as GameWin
	game_win.is_flawless = is_flawless
	game_win.menu_pressed.connect(_on_game_win_menu_pressed)
	add_child(game_win)
	game_win.show_animated()
	
func _show_game_loss():
	var game_loss = GAME_LOSS_SCENE.instantiate() as GameLoss
	game_loss.menu_pressed.connect(_on_game_loss_menu_pressed)
	game_loss.play_pressed.connect(_on_game_loss_play_pressed)
	add_child(game_loss)
	game_loss.show_animated()

func _on_game_countdown_countdown_finished():
	if bull.meta.tutorial_enabled:
		tooltip.switch_state(Tooltip.State.MOVEMENT)
	else:
		bull_hud.start()
		
	matador.is_input_enabled = true
	
	audio_player.play_sound(GameAudioPlayer.SoundEffect.GATE_OPEN)
	audio_player.play_background(GameAudioPlayer.BackgroundTrack.GAME)
	
	bull.switch_state(Bull.State.ENTER)
	_init_health_pickup()
	
func _init_health_pickup():
	crowd.health_pickup.initiate_health()
	crowd.health_pickup.picked_up.connect(matador.heal)
	
func _on_game_countdown_tick():
	audio_player.play_sound(GameAudioPlayer.SoundEffect.ENTRANCE_COUNTDOWN)

func _on_exit_marker_reached():
	if has_lost:
		return
		
	await get_tree().create_timer(BOW_DELAY).timeout
	audio_player.play_background(GameAudioPlayer.BackgroundTrack.OUTRO)
	
	if is_flawless:
		crowd.throw_roses()
	
	_init_confetti()
	_unlock_next_level_if_needed()
	_update_completion()
	_show_game_win()
	
func _unlock_next_level_if_needed():
	var next_level = bull.meta.difficulty_key + 1
	if next_level < GameState.DIFFICULTY_UNLOCKED_KEYS.size():
		if GameState.get_data_value(GameState.DIFFICULTY_UNLOCKED_KEYS[next_level]) != true:
			GameState.set_data_value(GameState.DIFFICULTY_UNLOCKED_KEYS[next_level], true)
			tooltip.switch_state(Tooltip.State.LEVEL_UNLOCK)
	else:
		tooltip.switch_state(Tooltip.State.VICTORY)

func _update_completion():
	var current_value = GameState.get_data_value(GameState.DIFFICULTY_BEATEN_KEYS[bull.meta.difficulty_key])
	if current_value != GameState.DATA_VALUE_BULL_BEATEN_FLAWLESS:
		GameState.set_data_value(
			GameState.DIFFICULTY_BEATEN_KEYS[bull.meta.difficulty_key], 
			GameState.DATA_VALUE_BULL_BEATEN_FLAWLESS if is_flawless else GameState.DATA_VALUE_BULL_BEATEN
		)

func _init_confetti():
	confetti_timer = Timer.new()
	confetti_timer.one_shot = false
	confetti_timer.timeout.connect(start_confetti_timer)
	confetti_container.add_child(confetti_timer)
	start_confetti_timer()
	
func start_confetti_timer():
	create_confetti()
	confetti_timer.wait_time = randf_range(0.3, 1)
	confetti_timer.start()
	
func create_confetti():
	var confetti = CONFETTI_SCENE.instantiate() as Confetti
	
	var random_x = randf_range(20, get_viewport().get_visible_rect().size.x - 20)
	var random_y = randf_range(20, get_viewport().get_visible_rect().size.y - 20)
	confetti.position = Vector2(random_x, random_y)
	
	confetti_container.add_child(confetti)
	
	audio_player.play_sound(GameAudioPlayer.SoundEffect.CONFETTI)
	confetti.start()
	
func _hide_entities():
	var tween = get_tree().create_tween()
	tween.tween_property(entities_container, "modulate:a", 0, ENTITIES_HIDE_DURATION)
	await tween.finished
	
func _show_entities(animated: bool):
	if !animated:
		entities_container.modulate.a = 1
	else:
		var tween = get_tree().create_tween()
		tween.tween_property(entities_container, "modulate:a", 1, ENTITIES_SHOW_DURATION)
		await tween.finished
		
func _show_parry_focus_background():
	var tween = get_tree().create_tween()
	tween.tween_property(parry_focus_background, "modulate:a", 1, 0.5)

func _hide_parry_focus_background():
	var tween = get_tree().create_tween()
	tween.tween_property(parry_focus_background, "modulate:a", 0, 0.5)

func _on_bull_sound_requested(sound_effect: GameAudioPlayer.SoundEffect):
	audio_player.play_sound(sound_effect)

func _on_matador_sound_requested(sound_effect: GameAudioPlayer.SoundEffect):
	audio_player.play_sound(sound_effect)
	
func _on_matador_parry_started():
	if tooltip.visible && tooltip.current_state == Tooltip.State.PARRY:
		tooltip.hide_animated()
		
	matador.is_dash_input_enabled = true
	matador.is_wave_input_enabled = true
	bull.movement_time_scale = 1

func _on_matador_parry_ended():
	if is_parry_focus_background_visible:
		audio_player.update_filter_background_effect(false)
		_hide_parry_focus_background()

func _on_matador_hurt_started():
	is_flawless = false

func _on_tooltip_dismiss_started(state: Tooltip.State):
	if state == Tooltip.State.WAVE:
		matador.end_wave()
		matador.is_input_enabled = false
		matador.is_dash_input_enabled = false
		matador.is_wave_input_enabled = false

func _on_tooltip_dismissed(state: Tooltip.State):
	match state:
		Tooltip.State.MOVEMENT:
			await get_tree().create_timer(NEXT_TOOLTIP_DELAY).timeout
			tooltip.switch_state(Tooltip.State.DASH)
			matador.is_dash_input_enabled = true
		Tooltip.State.DASH:
			await get_tree().create_timer(NEXT_TOOLTIP_DELAY).timeout
			matador.is_wave_input_enabled = true
			bull_hud.start()
			tooltip.switch_state(Tooltip.State.WAVE)

func _on_shake_requested(strength: ScreenShake.ShakeStrength):
	screen_shake.shake_screen(strength)

func _on_game_win_menu_pressed():
	_on_menu_pressed()

func _on_game_loss_menu_pressed():
	_on_menu_pressed()

func _on_game_loss_play_pressed():
	audio_player.stop_background()
	await _hide_entities()
	await get_tree().create_timer(MENU_REQUEST_DELAY).timeout
	play_requested.emit()
	
func _on_menu_pressed():
	audio_player.stop_background()
	tooltip.hide_animated()
	await _hide_entities()
	await get_tree().create_timer(MENU_REQUEST_DELAY).timeout
	menu_requested.emit()

func _on_bull_parry_tooltip_requested():
	audio_player.update_filter_background_effect(true)
	_show_parry_focus_background()
	tooltip.switch_state(Tooltip.State.PARRY)
