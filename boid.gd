extends CharacterBody2D

@export var debug := false
@onready var collision_polygon_2d := $CollisionPolygon2D
@onready var polygon_2d := $Polygon2D
@onready var label = $Label

@onready var velocity_line = $VelocityLine
@onready var desired_line = $DesiredLine
@onready var steering_line = $SteeringLine

var boids_in_range := []

var max_speed = 100
var screen_size : Vector2
var steering_force := Vector2.ZERO
var mass := 50

func _ready():
	screen_size = get_viewport_rect().size
	collision_polygon_2d.polygon = polygon_2d.polygon
	
	randomize()
	#velocity = Vector2(randf_range(-1,1),randf_range(-1,1)) * randf_range(0, max_speed)
	velocity = Vector2(randf_range(-1,1),randf_range(-1,1)).normalized() * randf_range(0, max_speed)
	#velocity = Vector2(randf_range(-1,1),randf_range(-1,1)).normalized() * max_speed
	#velocity.length() = 10
	polygon_2d.color = Color(randf_range(0,1),randf_range(0,1),randf_range(0,1),1)


func _physics_process(_delta):
	rotation = velocity.angle()

	if debug :
		velocity_line.clear_points()
		velocity_line.add_point(Vector2.ZERO)
		velocity_line.add_point(velocity)
		velocity_line.global_rotation = 0
	if not debug :
		velocity_line.clear_points()
		
	#str() converts to string
	#snapped can round numbers (acytually sets steps)
	label.text = str(snapped(velocity.normalized(), Vector2(0.01, 0.01)), snapped(velocity.length(),1))
	label.position = position + Vector2(15,-25)
	
	#disable it and set the collision layer of the physics layer from the tileset back to 1
	torus_world()
	#alignment(1)
	#mouse following

	#steering_force = steering_to_mouseposition() / mass
	steering_force = Vector2.ZERO
	steering_force += steering_vector(alignment())
	steering_force += steering_vector(cohesion()) 
	steering_force += steering_vector(separation()) 
	#cohesion(1)
	#separation(1)
	#apperantly delta is automatically applied in move and slide?
	#var total_steering_direction = (alignment(1) + cohesion(1) + separation(1)) / 3
	#velocity += total_steering_direction
	#velocity += acceleration
	#F = M x a 
	velocity += steering_force / mass
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


func alignment() -> Vector2:
	#only if there are boids in range
	var target_position := Vector2.ZERO
	if boids_in_range.size() > 0:
		#we "align" their directions and their speed (= together their velocity)
		var avgVelocity = Vector2.ZERO
		
		
		#loop over all boids in range and add their directions
		for boid in boids_in_range:
			
			avgVelocity += boid.velocity

		avgVelocity = avgVelocity / boids_in_range.size()
		
		#the position we want to steer to is our position + the averge postition of the group
		target_position = position + avgVelocity
		#return steering_vector(target_position)
		#velocity += steering_vector(target_position) * weight
	return target_position

func cohesion() -> Vector2:
	#only if there are boids in range
	var target_position := Vector2.ZERO
	if boids_in_range.size() > 0:
		#look for the average position (the center) of the group
		var avgPosition = Vector2.ZERO

		#loop over all boids in range and add their directions
		for boid in boids_in_range:
			avgPosition += boid.position
			
		target_position = avgPosition / boids_in_range.size()
	return target_position

		
func separation() -> Vector2:
	#only if there are boids in range
	var target_position := Vector2.ZERO
	var distance := 0.0
	if boids_in_range.size() > 0:
		#we have our position and add the inverse of the average distance of all boids in the group
		var avgDifference = Vector2.ZERO
		var difference = Vector2.ZERO
		
		#loop over all boids in range and add their directions
		for boid in boids_in_range:
			distance = position.distance_to(boid.position)
			difference += position - ((boid.position - position) / distance)
			#avgDifference += (boid.position - position) * distance

		difference = difference / boids_in_range.size()
		target_position = difference #position + avgDifference
	return target_position
		
func _on_area_2d_area_entered(area):
	#add the boid to the array
	boids_in_range.append(area.get_parent())

func _on_area_2d_area_exited(area):
	#remove the boid to the array
	boids_in_range.erase(area.get_parent()) 
	
#returns a new velocity
func steering_vector(
	target_position : Vector2,
	#distance : float,
	) -> Vector2:
	
	#calculate the vector where the boid wants to go
	var desired_velocity = target_position - position
	#normalise this vector	
	#speed should be intrinsic (for now a speed is set in creation and it stays like that)
	#var scaled_desired_velocity = desired_velocity.normalized() * distance
	var scaled_desired_velocity = desired_velocity.normalized() * max_speed
	#devide it by its mass: how bigger the mass how smaller the vector (slower the turning)
	var steer = (scaled_desired_velocity - velocity)
	
	if debug :
		desired_line.clear_points()
		desired_line.add_point(Vector2.ZERO)
		desired_line.add_point(scaled_desired_velocity)
		desired_line.global_rotation = 0
	
		steering_line.clear_points()
		steering_line.add_point(velocity)
		steering_line.add_point(scaled_desired_velocity)
		steering_line.global_rotation = 0
	if not debug :
		desired_line.clear_points()
		steering_line.clear_points()
	#velocity = Vector2.ZERO
	return steer
	
func steering_to_mouseposition() -> Vector2:
	#var distance := position.distance_to(get_global_mouse_position())
	return steering_vector(get_global_mouse_position())

