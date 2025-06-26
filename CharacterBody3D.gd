extends CharacterBody3D

# Gravity
@export var gravity: float = 9.8
var falling_velocity: float = 0.0
var explosion = load("res://explosiondmg.tscn")
# Health
@export var max_health: int = 100
var current_health: int
var instance
# Knockback
var knockback_velocity: Vector3 = Vector3.ZERO
@export var knockback_decay: float = 5.0  # Higher = faster decay
# Death flag
var is_dying: bool = false  # Add this to prevent multiple explosions

func _ready():
	current_health = max_health

func _physics_process(delta):
	# Gravity
	if not is_on_floor():
		falling_velocity -= gravity * delta
	else:
		falling_velocity = 0.0
	
	# Apply knockback if any
	if knockback_velocity != Vector3.ZERO:
		velocity = knockback_velocity
		knockback_velocity = knockback_velocity.move_toward(Vector3.ZERO, knockback_decay * delta)
		move_and_slide()

func _hit(amount: int):
	if is_dying:  # Don't process hits if already dying
		return
	
	current_health -= amount
	print("Enemy took damage! Health:", current_health)
	
	if current_health <= 0:
		die()

func die():
	if is_dying:  # Prevent multiple calls to die()
		return
	
	is_dying = true  # Set the flag
	set_physics_process(false)
	
	# Create explosion effects
	$explosion.emitting = true
	$AudioStreamPlayer3D.play()
	
	# Spawn explosion only once
	instance = explosion.instantiate()
	instance.position = $Object_4.global_position
	instance.transform.basis = $Object_4.global_transform.basis
	get_parent().add_child(instance)
	
	# Hide the barrel
	$Object_4.visible = false
	
	# Wait before freeing
	await get_tree().create_timer(3.0).timeout
	queue_free()

func apply_knockback(source_position: Vector3, strength: float):
	var knockback_dir = (global_position - source_position).normalized()
	knockback_dir.y = 0.2  # Slight upward knockback
	knockback_velocity = knockback_dir * strength

func _on_area_3d_body_entered(body):
	if body.has_method("get_damage") and not is_dying:  # Don't process hits if dying
		var damage = body.get_damage()
		_hit(damage)
