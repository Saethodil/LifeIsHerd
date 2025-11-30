class_name BullMeta
extends Resource

@export_group("Level Selection")
@export var name: String
@export var difficulty: String
@export var difficulty_key: int
@export var bio: String
@export var icon_normal: Texture2D
@export var icon_focused: Texture2D
@export var icon_active: Texture2D
@export var icon_active_focused: Texture2D
@export var icon_disabled: Texture2D

@export_group("Gameplay")
@export var sprite_sheet: Texture2D
@export var available_movements: Array[Bull.State] = []
@export var available_attacks: Array[Bull.State] = []
@export var first_movement: Bull.State = Bull.State.APPROACH
@export var first_attack: Bull.State = Bull.State.STAB
@export var approach_speed: float = 45
@export var approach_max_time: float = -1
@export var angry_delay: float = 1
@export var charge_heat_seek: bool = false
@export var charge_count: int = 1
@export var charge_speed: float = 300
@export var frustration_decay_speed: float = 0
@export var max_health: float = 100
@export var tutorial_enabled: bool = false
