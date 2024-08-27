extends StaticBody2D

@onready var border_collision_polygon_2d = $BorderCollisionPolygon2D
@onready var border_polygon_2d = $BorderPolygon2D

# Called when the node enters the scene tree for the first time.
func _ready():
	border_collision_polygon_2d.polygon = border_polygon_2d.polygon
