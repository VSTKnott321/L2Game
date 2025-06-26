extends Node3D
class_name bullet_L

const SPEED = 50.0

@export var damage: int = 50  # Damage per hit

@onready var mesh = $MeshInstance3D
@onready var ray = $RayCast3D  # Raycast to detect hits

func get_damage():
	return damage

func _process(delta):
	# Move the bullet forward
	position += transform.basis * Vector3(0, 0, -SPEED) * delta

	# Check if RayCast3D is colliding with something
	if ray.is_colliding():
		var hit_object = ray.get_collider()

		# Ensure the object has a "_hit()" function before calling it
		if hit_object and hit_object.has_method("_hit"):
			hit_object._hit(damage)  # Apply damage

		queue_free()  # Destroy the bullet

func _on_timer_timeout():
	queue_free()  # Destroy bullet after time limit

