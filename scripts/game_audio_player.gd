extends Node

class_name GameAudioPlayer

@onready var background_stream_player: AudioStreamPlayer = $BackgroundStreamPlayer
@onready var entrance_stream_player: AudioStreamPlayer = $EntranceStreamPlayer
@onready var entrance_countdown_stream_player: AudioStreamPlayer = $EntranceCountdownStreamPlayer
@onready var gate_open_stream_player: AudioStreamPlayer = $GateOpenStreamPlayer
@onready var growl_stream_player: AudioStreamPlayer = $GrowlStreamPlayer
@onready var eat_stream_player: AudioStreamPlayer = $EatStreamPlayer
@onready var charge_stream_player: AudioStreamPlayer = $ChargeStreamPlayer
@onready var hurt_stream_player: AudioStreamPlayer = $HurtStreamPlayer
@onready var slash_stream_player: AudioStreamPlayer = $SlashStreamPlayer
@onready var confetti_stream_player: AudioStreamPlayer = $ConfettiStreamPlayer
@onready var stomp_stream_player: AudioStreamPlayer = $StompStreamPlayer
@onready var stomp_effect_stream_player: AudioStreamPlayer = $StompEffectStreamPlayer
@onready var flourish_effect_stream_player: AudioStreamPlayer = $FlourishEffectStreamPlayer

const AUDIO_BUS_INDEX_MUSIC = 1
const AUDIO_BUS_EFFECT_INDEX_FILTER = 0

var background_stream_playback: AudioStreamPlaybackInteractive:
	get():
		return background_stream_player.get_stream_playback()

enum SoundEffect {
	ENTRANCE,
	ENTRANCE_COUNTDOWN,
	GATE_OPEN,
	GROWL,
	EAT,
	CHARGE,
	HURT,
	SLASH,
	CONFETTI,
	STOMP,
	STOMP_EFFECT,
	FLOURISH
}

enum BackgroundTrack {
	INTRO,
	GAME,
	OUTRO,
	TRY_AGAIN
}

func _get_stream_player(effect: SoundEffect) -> AudioStreamPlayer:
	match effect:
		SoundEffect.ENTRANCE:
			return entrance_stream_player
		SoundEffect.ENTRANCE_COUNTDOWN:
			return entrance_countdown_stream_player
		SoundEffect.GATE_OPEN:
			return gate_open_stream_player
		SoundEffect.GROWL:
			return growl_stream_player
		SoundEffect.EAT:
			return eat_stream_player
		SoundEffect.CHARGE:
			return charge_stream_player
		SoundEffect.HURT:
			return hurt_stream_player
		SoundEffect.SLASH:
			return slash_stream_player
		SoundEffect.CONFETTI:
			return confetti_stream_player
		SoundEffect.STOMP:
			return stomp_stream_player
		SoundEffect.STOMP_EFFECT:
			return stomp_effect_stream_player
		SoundEffect.FLOURISH:
			return flourish_effect_stream_player
		_:
			return null

func play_sound(effect: SoundEffect):
	var stream_player = _get_stream_player(effect)
	if stream_player:
		stream_player.play()
		await stream_player.finished

func play_background(track: BackgroundTrack):
	if !background_stream_player.playing:
		background_stream_player.volume_db = 0
		
		var clip_index: int
		match track:
			BackgroundTrack.INTRO:
				clip_index = 0
			BackgroundTrack.GAME:
				clip_index = 1
			BackgroundTrack.OUTRO:
				clip_index = 2
			BackgroundTrack.TRY_AGAIN:
				clip_index = 3
		
		background_stream_player.stream.initial_clip = clip_index
		background_stream_player.play()
		
	var clip_name: String
	match track:
		BackgroundTrack.INTRO:
			clip_name = "intro"
		BackgroundTrack.GAME:
			clip_name = "game"
		BackgroundTrack.OUTRO:
			clip_name = "outro"
		BackgroundTrack.TRY_AGAIN:
			clip_name = "try_again"

	var current_clip_name = background_stream_player.stream.get_clip_name(background_stream_playback.get_current_clip_index())
	if clip_name == current_clip_name:
		return
		
	background_stream_playback.switch_to_clip_by_name(clip_name)

func update_filter_background_effect(enabled: bool):
	AudioServer.set_bus_effect_enabled(AUDIO_BUS_INDEX_MUSIC, AUDIO_BUS_EFFECT_INDEX_FILTER, enabled)

func stop_background(duration: float = 1.0):
	if duration > 0:
		var tween = get_tree().create_tween()
		tween.tween_property(background_stream_player, "volume_linear", 0, duration)
		await tween.finished
	
	background_stream_player.stop()
