extends CharacterBody2D

@onready var collision_polygon_2d := $CollisionPolygon2D
@onready var polygon_2d := $Polygon2D

@onready var ray_folder := $RayFolder.get_children()
var boids_in_range := []

#TODO
#set a random speed and a max speen and boid cant go faster than max but it can mimic the speed op the neighbours
var boid_speed := 100.0
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
	#velocity is the direction multiplied with the speed
	velocity = direction * boid_speed
	#rotation is the direction but then an angle in radiants (and because the triangle sprite faces up we turn it 90° or Pi/2)
	rotation = direction.angle() + PI/2
	
	#disable it and set the collision layer of the physics layer from the tileset back to 1
	torus_world()
	steering()
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


func steering():
	#only if there are boids in range
	if boids_in_range.size() > 0:
		var avgDir = Vector2.ZERO
		var avoid_collision := Vector2.ZERO

		#loop over all boids in range and add their directions
		for boid in boids_in_range:
			avgDir += boid.direction
			#avoid_collision -= (position - boid.position) * (50 / (position - boid.position).length())
			#print(position)
			#print(boid.position)
			#print((position - boid.position).length())
		#normalise the average direction
		avgDir = avgDir.normalized()
		
		#set this direction to a value between the average direction and this direction
		#last parameter is the percantage of how much the direction is changed (speed of turning in that direction)
		direction = lerp(direction, avgDir, 0.05)

	

func _on_area_2d_area_entered(area):
	#add the boid to the array
	boids_in_range.append(area.get_parent())

func _on_area_2d_area_exited(area):
	#remove the boid to the array
	boids_in_range.erase(area.get_parent()) 
	
