extends CharacterBody2D

@onready var collision_polygon_2d := $CollisionPolygon2D
@onready var polygon_2d := $Polygon2D

@onready var ray_folder := $RayFolder.get_children()
var boids_in_range := []
var boid_velocity := Vector2.ZERO
var boid_speed := 7.0
var screen_size : Vector2
var movv := 48

var direction: Vector2

func _ready():
	screen_size = get_viewport_rect().size
	randomize()
	direction = Vector2.RIGHT
	collision_polygon_2d.polygon = polygon_2d.polygon
	

func _physics_process(delta):
	position = position * direction * delta
	move_and_slide()
