extends CharacterBody2D

@onready var collision_polygon_2d := $CollisionPolygon2D
@onready var polygon_2d := $Polygon2D

@onready var ray_folder := $RayFolder.get_children()
var boids_in_range := []
var boid_speed := 100.0
var screen_size : Vector2
var movv := 48
var number: int

var direction: Vector2

func _ready():
	screen_size = get_viewport_rect().size
	randomize()
	direction = Vector2(randf_range(-1,1),randf_range(-1,1))
	#print(direction)
	collision_polygon_2d.polygon = polygon_2d.polygon
	polygon_2d.color = Color(randf_range(0,1),randf_range(0,1),randf_range(0,1),1)

func _physics_process(_delta):
	velocity = direction * boid_speed
	var min_angle = rotation
	#angle_to_point returns the angle between the line connecting the two points and the X axis, in radians.
	var max_angle = velocity.angle_to_point(Vector2.ZERO) - PI/2
	rotation = lerp_angle(min_angle, max_angle,0.4)
	
	#disable it and set the collision layer of the physics layer from the tileset back to 1
	torus_world()
	
	#apperantly delta is automatically applied in move and slide?
	move_and_slide()


func torus_world():
	if position.x < 0:
		position.x = screen_size.x
	if position.x > screen_size.x:
		position.x = 0
	if position.y < 0:
		position.y = screen_size.y
	if position.y > screen_size.y:
		position.y = 0





func _on_area_2d_area_entered(area):
	if area != self and area.is_in_group("boid_area"): #dont think the self check is needed (and area also not probably)
		#prints("entered")
		boids_in_range.append(area.get_parent().number)
		prints("enter", number, "sees", boids_in_range)


func _on_area_2d_area_exited(area):
	#print("exited")
	# using lambda function filter wants a function, i is the element
	#boids_in_range.filter(func(i): return i != area.get_parent().number)
	# The callable's method should take one Variant parameter (the current array element) and return a boolean value.


	#boids_in_range = boids_in_range.filter(func(i): return number != i) 
	boids_in_range.erase(area.get_parent().number) 
	prints("exit", number, "sees", boids_in_range)
