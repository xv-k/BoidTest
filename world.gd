extends Node2D
@onready var tile_map = $TileMap
var counter = 0

var boid_scene: PackedScene = preload("res://boid.tscn")

func _ready():
	pass


func _process(delta):
	if Input.is_action_just_released("addBoid"):
		create_boid()

func create_boid():
	var boid = boid_scene.instantiate()
	boid.number = counter
	counter += 1
	$Boids.add_child(boid)
	boid.global_position = get_global_mouse_position()
	
