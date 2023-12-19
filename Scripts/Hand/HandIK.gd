
extends Camera3D

@onready var object = $"MeshInstance3D"

var base_pos = Vector3(0,9.23,9.28)
var base_rot = Vector3(-49,0,0)


var second_pos = Vector3(0,1,9.28)
var second_rot = Vector3(0,0,0)


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


var is_holding = false

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if(!is_holding):
		global_position = global_position.lerp(base_pos,delta)	
		global_rotation_degrees = global_rotation_degrees.lerp(base_rot, delta)
	else:
		global_position = global_position.lerp(second_pos,delta)	
		global_rotation_degrees = global_rotation_degrees.lerp(second_rot, delta)
		
	var mouse = get_viewport().get_mouse_position()
	print(mouse)
	mouse = Vector2(mouse.x, mouse.y)
	var angle_ray = project_ray_normal(mouse)
	var angle_power = global_position.y/angle_ray.y
	angle_ray *= angle_power
	object.global_position = global_position - angle_ray - Vector3(0,0,0)
	print(position - angle_ray)
	pass
	
func _input(ev):
	if ev is InputEventKey and ev.keycode  == KEY_K and ev.pressed:
		is_holding = !is_holding
