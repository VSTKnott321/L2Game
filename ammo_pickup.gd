extends Node3D

@export var ammo_amount: int = 30
@onready var area = $Area3D
@onready var pickup_sound = $AudioStreamPlayer
@onready var mesh = $MeshInstance3D  # Your visual representation


func _ready():
	area.body_entered.connect(_on_body_entered)

func _on_body_entered(body: Node3D):
	if body.has_method("add_ammo"):
		# Disable further collisions
		area.set_deferred("monitoring", false)
		
		# Hide the mesh
		mesh.visible = false
		pickup_sound.play()
		
		# Add ammo to player
		body.add_ammo(ammo_amount)
		
		# Wait briefly before freeing to let effects play
		await get_tree().create_timer(0.5).timeout
		queue_free()
