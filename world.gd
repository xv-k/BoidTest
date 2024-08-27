extends Node2D

var boid_scene: PackedScene = preload("res://boid.tscn")
# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if Input.is_action_just_released("addBoid"):
		create_boid()

func create_boid():
	var boid = boid_scene.instantiate()
	$Boids.add_child(boid)
	boid.global_position = get_global_mouse_position()
