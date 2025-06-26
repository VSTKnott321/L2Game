extends Node3D
class_name kick_dmg

@export var damage: int = 1
@export var knockback_strength: float = 20.0  # Adjust knockback force

@onready var particles = $GPUParticles3D
@onready var mesh = $MeshInstance3D
@onready var ray = $RayCast3D

const SPEED = 5


func get_damage():
	return damage

func _ready():
	particles.emitting = true

func _process(delta):
	# Move the bullet forward
	position += transform.basis * Vector3(0, 0, -SPEED) * delta

	# Check for collision
	if ray.is_colliding():
		var hit_object = ray.get_collider()
		var collision_normal = ray.get_collision_normal()

		if hit_object:
			# Apply damage if the enemy has a "_hit()" function
			if hit_object.has_method("_hit"):
				hit_object._hit(damage)

			# Apply knockback if the enemy has an "apply_knockback()" function
			if hit_object.has_method("apply_knockback"):
				# Use the projectile's forward direction for knockback
				var knockback_dir = -global_transform.basis.z.normalized()
				knockback_dir.y = 0  # Prevent vertical knockback
				hit_object.apply_knockback(knockback_dir, knockback_strength)

func _on_timer_timeout():
	queue_free()
