extends CanvasLayer

class_name Tooltip

signal dismiss_started(state: State)
signal dismissed(state: State)

@export var bull: Bull
@export var matador: Matador

@onready var text_container: Control = %TextContainer
@onready var label: RichTextLabel = %Label

var tooltip_tracker_factory: TooltipTrackerFactory = TooltipTrackerFactory.new()
var current_state: State
var current_tooltip_tracker: TooltipTracker

const SHOW_ANIMATION_DURATION = 0.5
const HIDE_ANIMATION_DURATION = 0.5

enum State {
	MOVEMENT,
	DASH,
	WAVE,
	PARRY,
	LEVEL_UNLOCK,
	VICTORY
}

func switch_state(state: State):
	if current_tooltip_tracker != null:
		current_tooltip_tracker.queue_free()

	label.text = _get_tooltip_text(state)
	
	current_state = state
	current_tooltip_tracker = tooltip_tracker_factory.get_tooltip_tracker(state)
	current_tooltip_tracker.setup(bull, matador)
	current_tooltip_tracker.finished.connect(_on_tracker_finished)
	
	add_child(current_tooltip_tracker)
	
	_show_animated()

func hide_animated():
	var tween = get_tree().create_tween()
	tween.tween_property(text_container, "position:y", 0, HIDE_ANIMATION_DURATION)
	await tween.finished
	hide()

func _show_animated():
	show()
	var tween = get_tree().create_tween()
	tween.tween_property(text_container, "position:y", -1 * text_container.size.y, SHOW_ANIMATION_DURATION)
	
func _get_tooltip_text(state: State) -> String:
	match state:
		State.MOVEMENT:
			return "Use WASD or LEFT/RIGHT/UP/DOWN to MOVE"
		State.DASH:
			return "Press SPACE while moving to DASH"
		State.WAVE:
			return "Hold X to [wave]WAVE[/wave]"
		State.PARRY:
			return "Press SPACE to FLOURISH against CHARGE"
		State.LEVEL_UNLOCK:
			return "New level unlocked!"
		State.VICTORY:
			return "Thanks for playing!!"
		_:
			return ""

func _on_tracker_finished():
	dismiss_started.emit(current_state)
	await hide_animated()
	dismissed.emit(current_state)
