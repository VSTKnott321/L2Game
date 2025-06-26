extends Node3D

@onready var spawns = $spawns

var enemy = preload("res://enemy.tscn")  # Use preload for efficiency

func _ready():
	randomize()  # Randomize RNG seed

func _get_random_child(parent_node):
	if parent_node.get_child_count() == 0:
		print("No spawn points available!")
		return null
	
	var random_id = randi() % parent_node.get_child_count()  # Fix indentation issue
	return parent_node.get_child(random_id)

func _on_spawn_timer_timeout():
	var spawn_point = _get_random_child(spawns)
	if spawn_point == null:
		return  # Don't proceed if there's no spawn point

	var instance = enemy.instantiate()
	instance.global_position = spawn_point.global_position  # Correctly set position
	get_tree().current_scene.add_child(instance)  # Add to the main scene to avoid errors
