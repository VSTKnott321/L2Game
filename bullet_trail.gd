extends MeshInstance3D


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

func init(pos1, pos2):
	var draw_mesh = ImmediateMesh.new()
	mesh = draw_mesh



# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
