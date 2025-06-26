extends Node3D  # or Area2D for 2D

@export var target_scene: String = "res://world_2.tscn"
@export var spawn_point_name: String = "PlayerSpawn"  # Name of the marker in the target scene

func _on_body_entered(body):
	if body.is_in_group("Player"):
		change_level()

func change_level():
	# Save any persistent data you need here
	
	# Load the target scene
	var next_level = load(target_scene).instantiate()
	
	# Get the tree and current scene
	var tree = get_tree()
	var current_scene = tree.current_scene
	
	# Add the new scene as a child (temporarily)
	tree.root.add_child(next_level)
	
	# Find the spawn point in the new scene
	var spawn_point = next_level.find_child(spawn_point_name)
	if spawn_point:
		# Move the player to the spawn point
		var player = current_scene.find_child("Player")  # Adjust as needed
		if player:
			player.global_transform = spawn_point.global_transform
	
	# Remove the current scene
	tree.current_scene.queue_free()
	tree.current_scene = target_scene
