extends CharacterBody3D

var speed 
const SUPER_SPEED = 45.0
const WALK_SPEED = 5.0
const SPRINT_SPEED = 10.0
const KICK_SPEED = 12.0
const JUMP_VELOCITY = 6.5
const SENSETIVITY = 0.005

const BOB_FREQ = 2.0
const BOB_AMP = 0.08
var t_bob = 0

#fov variables
const BASE_FOV = 75.0
const FOV_CHANGE = 1.5
var shoot_avalible = true
var gravity = 3.0
@onready var shoot_timer = $shoot_timer
var ssgbullet = load("res://shotgun_blast.tscn")
var pbullet = load("res://P_Bullet.tscn")
var lgbullet = load("res://levergun_bullet.tscn")
var  rckbullet = load("res://rocket.tscn")
var kickobj = load("res://kick_obj.tscn")
var GCBullet = load("res://gauss_bolt.tscn")
var instance
var DBJump = 2


#what ammo is being fired depending on weapon type
var PPistolShot = false
var SSGunShot = false
var SMGShot = false
var RocketShot = false
var  Macshot = false
var GauShot = false


#fire rate variables



@onready var pshootsound = $Pshootsound
@onready var ssgshootsound = $SSGSound
@onready var lgshootsound = $LGSound

@onready var raycast3d = $head/Camera3D/AimRay
@onready var PPistol = $CanvasLayer/PPistolBase/PPistol
@onready var head = $head
@onready var camera = $head/Camera3D
@onready var SSGun = $CanvasLayer/SSGBase/SSG
@onready var SMG = $CanvasLayer/SMGBase/smg
@onready var smg_visible = $CanvasLayer/SMGBase
@onready var kick = $CanvasLayer/kickbase/kick
@onready var PGL = $CanvasLayer/PGLBase
@onready var MAC = $CanvasLayer/macbase
@onready var GAU = $"CanvasLayer/gaussbase"
@onready var PRifle = $CanvasLayer/PRifleBase

func _ready():
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)






func _input(event: InputEvent) -> void:
	if event is InputEventMouseMotion:
		# Always allow horizontal rotation
		head.rotate_y(-event.relative.x * SENSETIVITY)
		
		# Vertical rotation with different restrictions based on ground state
		if is_on_floor():
			# When grounded, restrict vertical look to normal human range
			var new_angle = camera.rotation.x - event.relative.y * SENSETIVITY
			camera.rotation.x = clamp(new_angle, deg_to_rad(-90), deg_to_rad(90))
		else:
			# When airborne, allow full rotation
			camera.rotate_x(-event.relative.y * SENSETIVITY)
			# Optional: You might still want some limits even in air
			# camera.rotation.x = clamp(camera.rotation.x, deg_to_rad(-180), deg_to_rad(180))
			# camera.rotation.x = clamp(camera.rotation.x, deg_to_rad(-180), deg_to_rad(180))
 




func _physics_process(delta):
	# Add the gravity.
	if not is_on_floor():
		velocity.y -= gravity * delta




	# Handle Jump.
	if is_on_floor() :
		DBJump = 1.0

	if Input.is_action_just_pressed("jump") and DBJump >= 0 :
		velocity.y = JUMP_VELOCITY
		DBJump = DBJump - 1.0

	if Input.is_action_pressed("down"):
		gravity = 20.0
	elif Input.is_action_pressed("up"):
		gravity = -9.8
	else:
		gravity = 9.8


	#handle sprint
	if Input.is_action_pressed("sprint"):
		speed = SPRINT_SPEED
	elif Input.is_action_pressed("superspeed"):
		speed = SUPER_SPEED
	elif Input.is_action_just_pressed("kick"):
		kickdash()
	else:
		speed = WALK_SPEED




	#handle shooting semi auto
	if Input.is_action_just_pressed("shoot"):
			shoot()

	#handle shooting full auto
	if Input.is_action_pressed("shoot"):
		ShootAuto()



#equip pistol
	if Input.is_action_just_pressed("equip1"):
		$CanvasLayer/SMGBase.hide()
		$CanvasLayer/SSGBase.hide()
		$CanvasLayer/PPistolBase.show()
		$CanvasLayer/PGLBase.hide()
		$CanvasLayer/macbase.hide()
		$CanvasLayer/gaussbase.hide()
		PPistolShot = true
		SSGunShot = false
		SMGShot = false
		RocketShot = false
		Macshot = false
		GauShot = false

#equip super shotgun
	if Input.is_action_just_pressed("equip2"):
		$CanvasLayer/SMGBase.hide()
		$CanvasLayer/SSGBase.show()
		$CanvasLayer/PPistolBase.hide()
		$CanvasLayer/PGLBase.hide()
		$CanvasLayer/macbase.hide()
		$CanvasLayer/gaussbase.hide()
		SSGunShot = true
		PPistolShot = false
		SMGShot = false
		RocketShot = false
		Macshot = false
		GauShot = false

#equip lever action rifle
	if Input.is_action_just_pressed("equip3"):
		$CanvasLayer/SMGBase.show()
		$CanvasLayer/SSGBase.hide()
		$CanvasLayer/PPistolBase.hide()
		$CanvasLayer/PGLBase.hide()
		$CanvasLayer/macbase.hide()
		$CanvasLayer/gaussbase.hide()
		SMGShot = true
		SSGunShot = false
		PPistolShot = false
		RocketShot = false
		Macshot = false
		GauShot = false

#equip rocket gun
	if Input.is_action_just_pressed("equip4"):
		$CanvasLayer/SMGBase.hide()
		$CanvasLayer/SSGBase.hide()
		$CanvasLayer/PPistolBase.hide()
		$CanvasLayer/PGLBase.show() 
		$CanvasLayer/macbase.hide()
		$CanvasLayer/gaussbase.hide()
		SMGShot = false
		SSGunShot = false
		PPistolShot = false
		RocketShot = true
		Macshot = false
		GauShot = false

#equip mac-11
	if Input.is_action_just_pressed("equip5"):
		$CanvasLayer/SMGBase.hide()
		$CanvasLayer/SSGBase.hide()
		$CanvasLayer/PPistolBase.hide()
		$CanvasLayer/PGLBase.hide()
		$CanvasLayer/macbase.show()
		$CanvasLayer/gaussbase.hide()
		SMGShot = false
		SSGunShot = false
		PPistolShot = false
		RocketShot = false
		Macshot = true
		GauShot = false
		
		
		
#equip gauss gun
	if Input.is_action_just_pressed("equip6"):
		$CanvasLayer/SMGBase.hide()
		$CanvasLayer/SSGBase.hide()
		$CanvasLayer/PPistolBase.hide()
		$CanvasLayer/PGLBase.hide()
		$CanvasLayer/macbase.hide()
		$CanvasLayer/gaussbase.show()
		SMGShot = false
		SSGunShot = false
		PPistolShot = false
		RocketShot = false
		Macshot = false
		GauShot = true

	if Input.is_action_just_pressed("kick"):
		$CanvasLayer/SMGBase.hide()
		$CanvasLayer/SSGBase.hide()
		$CanvasLayer/PPistolBase.hide()
		$CanvasLayer/PGLBase.hide()
		$CanvasLayer/kickbase.show()
		$CanvasLayer/macbase.hide()
		$CanvasLayer/gaussbase.hide()
		GauShot = false
		SMGShot = false
		SSGunShot = false
		PPistolShot = false
		RocketShot = false
		kick.play("default")
		await get_tree().create_timer(0.27).timeout
		# Instantiate the kick object after the delay
		var instance = kickobj.instantiate()
		instance.position = raycast3d.global_position
		instance.transform.basis = raycast3d.global_transform.basis
		get_parent().add_child(instance)
		# Wait 0.8 seconds before hiding the kickbase
		await get_tree().create_timer(0.8).timeout
		$CanvasLayer/kickbase.hide()






	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	var input_dir = Input.get_vector("left_walk", "right_walk", "forward_walk", "back_walk")
	var direction = (head.transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	if is_on_floor():
		if direction:
			velocity.x = direction.x * speed
			velocity.z = direction.z * speed
		else:
			velocity.x = lerp(velocity.x, direction.x * speed, delta * 7.0)
			velocity.z = lerp(velocity.z, direction.z * speed, delta * 7.0)
	else:
		velocity.x = lerp(velocity.x, direction.x * speed, delta * 3.0)
		velocity.z = lerp(velocity.z, direction.z * speed, delta * 3.0)
	
	
#headbob
	t_bob += delta * velocity.length() * float(is_on_floor())
	camera.transform.origin = _headbob(t_bob)
	move_and_slide()
	
	#handle fov
	var velocity_clamped = clamp(velocity.length(), 0.5, SPRINT_SPEED * 2)
	var target_fov = BASE_FOV + FOV_CHANGE * velocity_clamped
	camera.fov = lerp(camera.fov, target_fov, delta * 1.0)
	
	

func _headbob(time) -> Vector3:
	var pos = Vector3.ZERO
	pos.y = sin(time * BOB_FREQ) * BOB_AMP
	pos.x = cos(time * BOB_FREQ / 2) * BOB_AMP
	return pos


# how do i change ammo type depending on wether different shot variable is true of false?

func shoot():
	# Only proceed if there's ammo left
	if ammo <= 0:
		return
	
	SMG.play("shoot")
	SSGun.play("shoot")
	$CanvasLayer/gaussbase/GCannon.play("shoot")
	$CanvasLayer/HPistolBase/Hpistol.play("shoot")
	
	if SSGunShot and shoot_avalible:
		shoot_timer.start(0.3)
		ammo -= 1
		ammo = max(ammo, 0)
		shoot_avalible = false
		ssgshootsound.play()
		instance = ssgbullet.instantiate()
		instance.position = raycast3d.global_position
		instance.transform.basis = raycast3d.global_transform.basis
		get_parent().add_child(instance)

	if SMGShot and shoot_avalible:
		shoot_timer.start(0.588)
		ammo -= 1
		ammo = max(ammo, 0)
		shoot_avalible = false
		lgshootsound.play()
		instance = lgbullet.instantiate()
		instance.position = raycast3d.global_position
		instance.transform.basis = raycast3d.global_transform.basis
		get_parent().add_child(instance)

	if GauShot and shoot_avalible:
		shoot_timer.start(0.27)
		ammo -= 1
		ammo = max(ammo, 0)
		shoot_avalible = false
		ssgshootsound.play()
		instance = GCBullet.instantiate()
		instance.position = raycast3d.global_position
		instance.transform.basis = raycast3d.global_transform.basis
		get_parent().add_child(instance)

func ShootAuto():
	# Only proceed if there's ammo left
	if ammo <= 0:
		return
	
	PPistol.play("shoot_anim")
	$CanvasLayer/macbase/mac.play("shoot")
	$CanvasLayer/PGLBase/Rocket.play("shoot")
	$CanvasLayer/PRifleBase/PlasmaRifle.play("shoot")

	if PPistolShot and shoot_avalible:
		ammo -= 1
		ammo = max(ammo, 0)
		shoot_timer.start(0.2)
		shoot_avalible = false
		pshootsound.play()
		instance = pbullet.instantiate()
		instance.position = raycast3d.global_position
		instance.transform.basis = raycast3d.global_transform.basis
		get_parent().add_child(instance)

	if RocketShot and shoot_avalible:
		ammo -= 1
		ammo = max(ammo, 0)
		shoot_timer.start(0.4)
		shoot_avalible = false
		pshootsound.play()
		instance = rckbullet.instantiate()
		instance.position = raycast3d.global_position
		instance.transform.basis = raycast3d.global_transform.basis
		get_parent().add_child(instance)

	if Macshot and shoot_avalible:
		ammo -= 1
		ammo = max(ammo, 0)
		shoot_timer.start(0.05)
		shoot_avalible = false
		lgshootsound.play()
		instance = lgbullet.instantiate()
		instance.position = raycast3d.global_position
		instance.transform.basis = raycast3d.global_transform.basis
		get_parent().add_child(instance)




func kickdash():
	$kick_timer.start()
	speed = KICK_SPEED

func _on_shoot_timer_timeout():
	shoot_avalible = true





func _on_kick_timer_timeout():
	speed = 0.0

@export var ammo: int = 30  # Starting ammo count

@onready var ammo_label =  $CanvasLayer/ammo/Label # Reference to the Label node

func _process(delta):
	ammo_label.text = "Ammo: " + str(ammo)  # Update the label text

# In your player script (where you have the ammo variable)
func add_ammo(amount: int) -> void:
	ammo += amount
	ammo_label.text = "Ammo: " + str(ammo)  # Update the UI


