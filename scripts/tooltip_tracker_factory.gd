extends Node

class_name TooltipTrackerFactory

var tooltip_trackers: Dictionary

func _init():
	tooltip_trackers = {
		Tooltip.State.MOVEMENT: TooltipMovementTracker,
		Tooltip.State.DASH: TooltipDashTracker,
		Tooltip.State.WAVE: TooltipWaveTracker,
		Tooltip.State.PARRY: TooltipParryTracker,
		Tooltip.State.LEVEL_UNLOCK: TooltipTracker,
		Tooltip.State.VICTORY: TooltipTracker
	}
	
func get_tooltip_tracker(state: Tooltip.State) -> TooltipTracker:
	return tooltip_trackers.get(state).new()
