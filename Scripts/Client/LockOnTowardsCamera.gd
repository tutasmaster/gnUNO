extends MeshInstance3D


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if(get_viewport().get_camera_3d() != null):
		var camera_pos = get_viewport().get_camera_3d().global_transform.origin
		camera_pos.y = -3
		look_at(-camera_pos, Vector3(0, 1, 0))
