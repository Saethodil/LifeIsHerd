extends BullState

class_name BullBowState
	
func _ready():
	bull.velocity = Vector2.ZERO
	bull.animation_player.play("idle")
