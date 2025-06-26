extends Node3D

@onready var area = $Area3D  # You want to reference the Area3D node, not the CollisionShape directly
var damage = 100

func get_damage():
	return damage



func _process(delta):
	# Area3D doesn't have is_colliding(), we need to check its overlapping bodies
	var overlapping_bodies = area.get_overlapping_bodies()
	for body in overlapping_bodies:
		# Ensure the object has a "_hit()" function before calling it
		if body.has_method("_hit"):
			body._hit(damage)  # Apply damage




func _on_timer_timeout():
	queue_free()
