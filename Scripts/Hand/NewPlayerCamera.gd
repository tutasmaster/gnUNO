extends Camera3D

@export var target : Node3D

# Called when the node enters the scene tree for the first time.
func _ready():
	Input.mouse_mode = Input.MOUSE_MODE_HIDDEN
	pass # Replace with function body.

func moveTarget(mouse):
	if(mouse.x > 0 && mouse.y > 0 && mouse.x < get_viewport().size.x && mouse.y < get_viewport().size.y):
		
		var angle_ray = project_ray_normal(mouse)
		var height_diff = global_position.y - 3.3
		
		var angle_power = height_diff/angle_ray.y
		if(angle_ray.y > 0):
			angle_ray *= 1000
			target.global_position = global_position + angle_ray
			return
		angle_ray *= angle_power
		target.global_position = (global_position - angle_ray)
		target.position += Vector3(0,0,0.25)

func _process(delta):
	
	var mouse = get_viewport().get_mouse_position()
	
	global_rotation_degrees = Vector3(-mouse.y, -mouse.x, 0)
	moveTarget(Vector2(get_viewport().size.x/2,get_viewport().size.y/2))
	
	
	pass
