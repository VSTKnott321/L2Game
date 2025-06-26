extends Node3D

@export var speed := 1.01  # Initial speed
@export var acceleration_factor := 4.0  # Multiplier per frame
@export var max_speed := 1000000.0  # Cap on max speed

@export var damage := 10  # Initial damage
@export var damage_growth := 40.0  # Damage increase per second
@export var max_damage := 500  # Cap on max damage

@onready var mesh = $MeshInstance3D
@onready var ray = $RayCast3D
@onready var particle = $GPUParticles3D

func get_damage():
	return damage

func _process(delta):
	# Exponential speed increase
	speed *= pow(acceleration_factor, delta)
	speed = min(speed, max_speed)  # Clamp speed

	# Linearly increase damage over time
	damage = min(damage + damage_growth * delta, max_damage)  # Clamp damage

	# Move forward
	position += transform.basis * Vector3(0, 0, -speed) * delta

	# Collision check
	if ray.is_colliding():
		var hit_object = ray.get_collider()
		explode()

		# Ensure the object has a "_hit()" function before calling it
		if hit_object and hit_object.has_method("_hit"):
			hit_object._hit(damage)  # Apply increased damage
			queue_free()  # Destroy the bullet

func explode():
	mesh.visible = false
	particle.emitting = true
	await get_tree().create_timer(1.0).timeout
	queue_free()

