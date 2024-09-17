extends Node2D
@onready var tile_map = $TileMap
var counter = 1

var boid_scene: PackedScene = preload("res://boid.tscn")

func _ready():
	pass
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
	boid.number = counter
	counter += 1
	#boid.global_position = get_global_mouse_position()
	boid.global_position = Vector2(randf_range(0, get_viewport_rect().size.x), randf_range(0, get_viewport_rect().size.y))
	#boid.global_position = Vector2(get_viewport_rect().size.x/2, get_viewport_rect().size.y/2)
	

func _on_check_button_toggled(toggled_on):
	if toggled_on:
		for boid in $Boids.get_children():
			boid.debug = true
	else:
		for boid in $Boids.get_children():
			boid.debug = false
