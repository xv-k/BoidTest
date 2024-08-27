extends CharacterBody2D

@onready var collision_polygon_2d = $CollisionPolygon2D
@onready var polygon_2d = $Polygon2D

func _ready():
	collision_polygon_2d.polygon = polygon_2d.polygon
	

func _physics_process(delta):
	move_and_slide()
