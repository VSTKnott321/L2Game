extends Node3D
class_name rocket

const SPEED = 30.0
const GRAVITY = -9.8  # Adjust gravity strength
const ARCX = -20
const ARCZ = 20

@export var move_speed: float = 5.0
@export var damage: int = 75  # Damage per hit
@onready var player: CharacterBody3D = get_tree().get_first_node_in_group("player")
@onready var mesh = $MeshInstance3D
@onready var ray = $RayCast3D 
@onready var particle = $GPUParticles3D
@onready var explosionsound = $AudioStreamPlayer3D

var velocity = Vector3.ZERO  # Stores movement speed

func _ready():
	velocity = transform.basis * Vector3(0, 0, -SPEED)  # Set initial movement

func _process(delta):
	velocity.y += GRAVITY * delta  # Apply gravity over time
	position += velocity * delta  # Move rocket


	# Check if RayCast3D is colliding with something
	if ray.is_colliding():
		var hit_object = ray.get_collider()
		
		# Ensure the object has a "_hit()" function before calling it
		if hit_object and hit_object.has_method("_hit"):
			hit_object._hit(damage)  # Apply damage
			
		explode()

func explode():
	mesh.visible = false
	particle.emitting = false
	$explosion.emitting = true
	explosionsound.play()
	await get_tree().create_timer(0.3).timeout
	queue_free()

func _on_timer_timeout():
	var direction = (player.global_position - global_position).normalized()
