extends Node3D

@export var speed := 50  # Initial speed


@export var damage := 100  # Initial damage


@onready var mesh = $MeshInstance3D
@onready var ray = $RayCast3D
@onready var particle = $GPUParticles3D
@onready var particle2 = $GPUParticles3D2

func get_damage():
	return damage

func _process(delta):


	# Move forward
	position += transform.basis * Vector3(0, 0, -speed) * delta

	# Collision check
	if ray.is_colliding():
		var hit_object = ray.get_collider()
		explode()

		# Ensure the object has a "_hit()" function before calling it
		if hit_object and hit_object.has_method("_hit"):
			hit_object._hit(damage)  # Apply increased damage


func explode():
	particle.emitting = true
	particle2.emitting = true
	await get_tree().create_timer(1.0).timeout
	particle.emitting = false
	particle2.emitting = false



func _on_timer_timeout():
	queue_free()
