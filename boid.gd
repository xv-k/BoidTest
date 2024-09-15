extends CharacterBody2D

@export var debug := false
@export var alignment_factor := 0.9
@export var cohesion_factor := 0.9
@export var separation_factor := 1.0

@onready var collision_polygon_2d := $CollisionPolygon2D
@onready var polygon_2d := $Polygon2D
@onready var label = $Label

var boids_in_range := []

var number := 0
var max_speed = 300
var screen_size : Vector2
var steering_force := Vector2.ZERO
var mass := 50

#for debug purposes (to draw the force lines)
var desired_velocity : Vector2
var arrow_size_factor := 0.3
@onready var velocity_line = $VelocityLine
@onready var desired_line = $DesiredLine
@onready var steering_line = $SteeringLine


func _ready():
	screen_size = get_viewport_rect().size
	collision_polygon_2d.polygon = polygon_2d.polygon
	
	randomize()
	velocity = Vector2(randf_range(-1,1),randf_range(-1,1)).normalized() * randf_range(30, max_speed)
	polygon_2d.color = Color(randf_range(0,1),randf_range(0,1),randf_range(0,1),1)


func _physics_process(_delta):
	rotation = velocity.angle()
		
	#str() converts to string
	#snapped can round numbers (acytually sets steps)
	label.text = str(snapped(velocity.normalized(), Vector2(0.01, 0.01)), snapped(velocity.length(),1))
	label.position = position + Vector2(15,-25)
	
	#disable it and set the collision layer of the physics layer from the tileset back to 1
	torus_world()
	
	steering_force = Vector2.ZERO
	
	#mouse following
	#steering_to_mouse_position()

	#steering force is calculated and added in each function
	alignment()
	cohesion()
	separation()

	
	
	#to show the force lines
	if debug :
		velocity_line.clear_points()
		desired_line.clear_points()
		steering_line.clear_points()
		
		velocity_line.add_point(Vector2.ZERO)
		velocity_line.add_point(velocity * arrow_size_factor)
		desired_line.add_point(Vector2.ZERO)
		desired_line.add_point(desired_velocity * arrow_size_factor)
		steering_line.add_point(velocity* arrow_size_factor)
		steering_line.add_point(desired_velocity * arrow_size_factor)
		
		velocity_line.global_rotation = 0
		desired_line.global_rotation = 0
		steering_line.global_rotation = 0
		
	if not debug :
		velocity_line.clear_points()
		desired_line.clear_points()
		steering_line.clear_points()
	
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


func alignment():
	#only if there are boids in range
	if boids_in_range.size() > 0:
		#we "align" their directions and their speed (= together their velocity)
		var avgVelocity = Vector2.ZERO
		#loop over all boids in range and add their directions
		for boid in boids_in_range:
			avgVelocity += boid.velocity
		avgVelocity /= boids_in_range.size()
		#the position we want to steer to is our position + the averge postition of the group
		var target_position = position + avgVelocity
		steering_force += steering_vector(target_position) * alignment_factor

func cohesion():
	#only if there are boids in range
	if boids_in_range.size() > 0:
		#look for the average position (the center) of the group
		var avgPosition = Vector2.ZERO
		#loop over all boids in range and add their directions
		for boid in boids_in_range:
			avgPosition += boid.position
		#avg position can be seen as the midpoint 
		var target_position = avgPosition / boids_in_range.size()
		steering_force += steering_vector(target_position) * cohesion_factor

		
func separation():
	#distance is used to scale the vector (closer is bigger, further is smaller)
	var distance := 0.0
	#only if there are boids in range
	if boids_in_range.size() > 0:
		var avgDifference = Vector2.ZERO
		#loop over all boids in range and add their directions
		for boid in boids_in_range:
			#calculate distance
			distance = position.distance_to(boid.position)
			#we have our position and substract the difference between the two positions
			# -> we come out at the other side but we divide by distance because we need the inverse of the distance
			avgDifference += position - ((boid.position - position) / distance)

		var target_position = avgDifference / boids_in_range.size()
		steering_force += steering_vector(target_position) * separation_factor

	
func _on_area_2d_area_entered(area):
	#add the boid to the array
	boids_in_range.append(area.get_parent())
	
func _on_area_2d_area_exited(area):
	#remove the boid to the array
	boids_in_range.erase(area.get_parent()) 
	
#returns a steering velocity (to add to the steering force)
func steering_vector(target_position : Vector2) -> Vector2:
	#calculate the vector where the boid wants to go
	desired_velocity = target_position - position
	#normalise this vector	
	desired_velocity = desired_velocity.normalized() * max_speed
	var steer = (desired_velocity - velocity)
	return steer
	
func steering_to_mouse_position():
	steering_force += steering_vector(get_global_mouse_position())

