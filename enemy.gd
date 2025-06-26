extends CharacterBody3D

@export var move_speed: float = 5.0
@onready var player: CharacterBody3D = get_tree().get_first_node_in_group("player")

# Gravity
@export var gravity: float = 9.8
var falling_velocity: float = 0.0

# Health
@export var max_health: int = 100
var current_health: int

# Knockback
var knockback_velocity: Vector3 = Vector3.ZERO
@export var knockback_decay: float = 5.0  # Higher = faster decay

# Sprite Animation
@onready var sprite: AnimatedSprite3D = $AnimatedSprite3D
var angle_to_animation = {
	0: "E",
	45: "NE",
	90: "N",
	135: "NW",
	180: "W",
	225: "SW",
	270: "S",
	315: "SE"
}
# Direction smoothing
var current_direction: Vector3 = Vector3.FORWARD  # Stores the enemy's current facing direction
var target_direction: Vector3 = Vector3.FORWARD   # Direction the enemy WANTS to go

 


func _ready():
	current_health = max_health

func _physics_process(delta):
 # Gravity and knockback logic (keep your existing code here)
	# ...

	if player == null:
		return

	# Gravity
	if not is_on_floor():
		falling_velocity -= gravity * delta
	else:
		falling_velocity = 0.0
	
	if player == null:
		return
	
	# Movement direction (horizontal only)
	var direction = (player.global_position - global_position).normalized()
	direction.y = 0
	
	# Combine movement, knockback, and gravity
	var horizontal_velocity = direction * move_speed + knockback_velocity
	velocity = Vector3(horizontal_velocity.x, falling_velocity, horizontal_velocity.z)
	
	# Apply knockback decay
	knockback_velocity = knockback_velocity.lerp(Vector3.ZERO, knockback_decay * delta)
	
	move_and_slide()

	# Face movement direction (optional, if you want the sprite to rotate)
	if direction.length() > 0.1:
		rotation.y = atan2(direction.x, direction.z)


func _process(delta):
	if !sprite or sprite.animation == "die":  # Skip if dead or no sprite
		return
	
	
	var camera = get_viewport().get_camera_3d()
	if not camera:
		return
	
	# Get direction from sprite to camera (ignore Y-axis)
	var dir_to_camera = global_transform.origin - camera.global_transform.origin
	dir_to_camera.y = 0
	
	# Convert direction to angle (0-360 degrees)
	var angle = rad_to_deg(dir_to_camera.normalized().angle_to(Vector3.FORWARD))
	angle = fposmod(angle, 360)  # Ensure 0-360 range
	
	# Find the closest angle in angle_to_animation
	var closest_angle = 0
	var min_diff = 360  # Start with maximum possible difference
	
	for key in angle_to_animation.keys():
		var diff = abs(key - angle)
		if diff < min_diff:
			min_diff = diff
			closest_angle = key
	
	# Play the corresponding animation (e.g., "walk_N", "idle_S")
	var anim_name = angle_to_animation[closest_angle]
	if sprite.sprite_frames.has_animation(anim_name):
		sprite.play(anim_name)
	else:
		print("Animation not found: ", anim_name)  # Debug missing animations

func _hit(amount: int):
	current_health -= amount
	print("Enemy took damage! Health:", current_health)
	
	if current_health <= 0:
		die()

func die():
	move_speed = 0
	set_physics_process(false)
	sprite.play("die")
	print("Enemy has died")
	await get_tree().create_timer(2.0).timeout
	queue_free()

func apply_knockback(source_position: Vector3, strength: float):
	var knockback_dir = (global_position - source_position).normalized()
	knockback_dir.y = 0.2  # Slight upward knockback
	knockback_velocity = knockback_dir * strength

func _on_area_3d_body_entered(body):
	if body.has_method("get_damage"):
		var damage = body.get_damage()
		_hit(damage)
