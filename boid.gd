extends CharacterBody2D

@onready var collision_polygon_2d := $CollisionPolygon2D
@onready var polygon_2d := $Polygon2D
@onready var label = $Label

@onready var ray_folder := $RayFolder.get_children()
var boids_in_range := []

#TODO
var max_speed = 250
var speed : float
var screen_size : Vector2

#number is a number given to the boid (at creation in the world script)
var number: int
#direction is the direction in a normalized vector
var direction: Vector2

func _ready():
	screen_size = get_viewport_rect().size
	collision_polygon_2d.polygon = polygon_2d.polygon
	
	randomize()
	direction = Vector2(randf_range(-1,1),randf_range(-1,1))
	polygon_2d.color = Color(randf_range(0,1),randf_range(0,1),randf_range(0,1),1)

func _physics_process(_delta):
	if speed > max_speed: speed = max_speed
	#velocity is the direction multiplied with the speed
	velocity = direction.normalized() * speed
	#rotation is the direction but then an angle in radiants (and because the triangle sprite faces up we turn it 90° or Pi/2)
	rotation = direction.angle() + PI/2
	#str() converts to string
	#snapped can round numbers (acytually sets steps)
	label.text = str(snapped(direction, Vector2(0.01, 0.01)), snapped(speed,1))
	label.position = position + Vector2(15,-25)
	#disable it and set the collision layer of the physics layer from the tileset back to 1
	torus_world()
	alignment()
	#cohesion()
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
		var avgDir = Vector2.ZERO
		var avgSpeed = 0

		#loop over all boids in range and add their directions
		for boid in boids_in_range:
			avgDir += boid.direction
			avgSpeed += boid.speed
			#avoid_collision -= (position - boid.position) * (50 / (position - boid.position).length())
			#print(position)
			#print(boid.position)
			#print((position - boid.position).length())
		avgDir = avgDir / boids_in_range.size()
		avgSpeed = avgSpeed / boids_in_range.size()
		#normalise the average direction
		#avgDir = avgDir.normalized()
		#set this direction to a value between the average direction and this direction
		#last parameter is the percantage of how much the direction is changed (speed of turning in that direction)
		#direction = lerp(direction, avgDir, 0.05)
		look_at(avgDir.orthogonal())  
		#direction = direction + avgDir
		speed = lerp(speed, avgSpeed, 0.05)
		
		#steering according to reinolds is desired - current
		#direction = avgDir - direction
		#speed = avgSpeed - speed

func cohesion():
	#only if there are boids in range
	if boids_in_range.size() > 0:
		var avgPosition = Vector2.ZERO
		var avgSpeed = 0
		#loop over all boids in range and add their positions
		for boid in boids_in_range:
			avgPosition += boid.position
			avgSpeed += boid.speed
		avgPosition = avgPosition / boids_in_range.size()
		avgSpeed = avgSpeed / boids_in_range.size()
		#normalise the average direction
		#avgDir = avgDir.normalized()
		#set this direction to a value between the average direction and this direction
		#last parameter is the percantage of how much the direction is changed (speed of turning in that direction)
		#var steering = position - avgPosition
		direction = lerp(position, avgPosition, 0.4)
		speed = lerp(speed, avgSpeed, 0.05)
		
func _on_area_2d_area_entered(area):
	#add the boid to the array
	boids_in_range.append(area.get_parent())

func _on_area_2d_area_exited(area):
	#remove the boid to the array
	boids_in_range.erase(area.get_parent()) 
	
