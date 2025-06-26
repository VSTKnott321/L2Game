extends Node3D
class_name bullet_ssg

@export var damage: int = 100  # Starting damage
@export var min_damage: int = 10  # Minimum damage threshold
@export var damage_falloff: float = 20.0
  # Damage reduction per second

@onready var particles = $GPUParticles3D
@onready var mesh = $MeshInstance3D
@onready var ray = $RayCast3D

const SPEED = 90.0

func get_damage():
	return damage

func _ready():
	particles.emitting = true

func _process(delta):
	# Move the bullet forward
	position += transform.basis * Vector3(0, 0, -SPEED) * delta

	# Reduce damage over time (damage can't go below min_damage)
	damage = max(damage - damage_falloff * delta, min_damage)

	# Check for collision
	if ray.is_colliding():
		var hit_object = ray.get_collider()
		mesh.visible = false
		particles.visible = false

		# Ensure the object has a "_hit()" function before calling it
		if hit_object and hit_object.has_method("_hit"):
			hit_object._hit(damage)  # Apply damage
			queue_free()  # Destroy the bullet

func _on_timer_timeout():
	queue_free()

