extends Node

class_name BullStateFactory

var states: Dictionary

func _init():
	states = {
		Bull.State.IDLE: BullIdleState,
		Bull.State.ENTER: BullEnterState,
		Bull.State.APPROACH: BullApproachState,
		Bull.State.GRAZE: BullGrazeState,
		Bull.State.RECOVERY: BullRecoveryState,
		Bull.State.EAT: BullEatState,
		Bull.State.ANGRY: BullAngryState,
		Bull.State.CHARGE: BullChargeState,
		Bull.State.BUMP: BullBumpState,
		Bull.State.STAB: BullStabState,
		Bull.State.SWIPE: BullSwipeState,
		Bull.State.STOMP: BullStompState,
		Bull.State.SPIN: BullSpinState,
		Bull.State.EXIT: BullExitState,
		Bull.State.BOW: BullBowState
	}
	
func get_state(state: Bull.State, args: Dictionary[String, Variant] = {}) -> BullState:
	var new_state = states.get(state).new()
	for arg_key in args:
		new_state.set(arg_key, args[arg_key])
	return new_state
