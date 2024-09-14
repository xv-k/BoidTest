extends Node2D
@onready var tile_map = $TileMap
var counter = 0

var boid_scene: PackedScene = preload("res://boid.tscn")

func _ready():
	for n in 100:
		create_boid()


func _process(_delta):
	if Input.is_action_just_released("addBoid"):
		create_boid()

func create_boid():
	var boid = boid_scene.instantiate()
	#we can add a "constructor" here (most logical way ist to create a fucntion in the boid that 
	#substritutes as a constructor = Named Constructors/Factory Methods design patters)
	$Boids.add_child(boid)
	#boid.global_position = get_global_mouse_position()
	boid.global_position = Vector2(randi_range(0, get_viewport_rect().size.x), randi_range(0, get_viewport_rect().size.y))
	
