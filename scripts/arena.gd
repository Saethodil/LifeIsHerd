extends Node2D

class_name Arena

@onready var wall: StaticBody2D = $Wall

func _ready():
	wall.add_child(_create_ring(2, 105))
	
func _create_ring(thickness: float, radius: float) -> CollisionPolygon2D:
	var collisionShape2D = CollisionPolygon2D.new()
	collisionShape2D.build_mode = CollisionPolygon2D.BUILD_SOLIDS
	var totalPoints = 360
	var pointsArc = PackedVector2Array()
	for angle in range(totalPoints + 1):
		var anglePoint = deg_to_rad(angle)
		pointsArc.push_back(Vector2(cos(anglePoint), sin(anglePoint)) * radius)
	for angle in range(totalPoints, -1, -1):
		var anglePoint: float = deg_to_rad(angle)
		pointsArc.push_back(Vector2(cos(anglePoint), sin(anglePoint)) * (radius - thickness))
	collisionShape2D.polygon = pointsArc
	return collisionShape2D
