extends CharacterBody2D

@onready var collision_polygon_2d := $CollisionPolygon2D
@onready var polygon_2d := $Polygon2D
@onready var label = $Label

var boids_in_range := []

var max_speed = 250
var screen_size : Vector2


func _ready():
	screen_size = get_viewport_rect().size
	collision_polygon_2d.polygon = polygon_2d.polygon
	
	randomize()
	velocity = Vector2(randf_range(-1,1),randf_range(-1,1)) * randf_range(0, max_speed)
	polygon_2d.color = Color(randf_range(0,1),randf_range(0,1),randf_range(0,1),1)


func _physics_process(_delta):
	rotation = velocity.angle()
	
	#str() converts to string
	#snapped can round numbers (acytually sets steps)
	label.text = str(snapped(velocity.normalized(), Vector2(0.01, 0.01)), snapped(velocity.length(),1))
	label.position = position + Vector2(15,-25)
	
	#disable it and set the collision layer of the physics layer from the tileset back to 1
	torus_world()
	alignment()
	#mouse following
	#steering_to_mouseposition()
	cohesion()
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


func alignment():
	#only if there are boids in range
	if boids_in_range.size() > 0:
		#we "align" their directions and their speed (= together their velocity)
		var avgVelocity = Vector2.ZERO

		#loop over all boids in range and add their directions
		for boid in boids_in_range:
			avgVelocity += boid.velocity

		avgVelocity = avgVelocity / boids_in_range.size()
		var target_position = position + avgVelocity
		
		velocity += steering_vector(target_position)
		

func cohesion():
	#only if there are boids in range
	if boids_in_range.size() > 0:
		#we "align" their directions and their speed (= together their velocity)
		var avgPosition = Vector2.ZERO

		#loop over all boids in range and add their directions
		for boid in boids_in_range:
			avgPosition += boid.position

		avgPosition = avgPosition / boids_in_range.size()
		
		velocity += steering_vector(avgPosition)
		
func _on_area_2d_area_entered(area):
	#add the boid to the array
	boids_in_range.append(area.get_parent())

func _on_area_2d_area_exited(area):
	#remove the boid to the array
	boids_in_range.erase(area.get_parent()) 
	
#returns a new velocity
func steering_vector(
	target_position : Vector2,
	max_speed := 150,
	mass := 120.0
	) -> Vector2:
	
	#calculate the vector where the boid wants to go
	var desired_velocity = target_position - position
	#normalise this vector	
	#speed should be intrinsic (for now a speed is set in creation and it stays like that)
	var scaled_desired_velocity = desired_velocity.normalized() * max_speed
	#devide it by its mass: how bigger the mass how smaller the vector (slaower the turning)
	var steer = (scaled_desired_velocity - velocity) / mass
	#velocity = Vector2.ZERO
	return steer
	
func steering_to_mouseposition():
	velocity += steering_vector(get_global_mouse_position())

