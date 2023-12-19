class_name PlayerCamera
extends Camera3D

@export var reference_poses : Array[Camera3D]
@export var target : Node3D
@export var area3d: Area3D
@export var ik : SkeletonIK3D
var current_pose = 0

# Called when the node enters the scene tree for the first time.
func _ready():
	Input.mouse_mode = Input.MOUSE_MODE_HIDDEN
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	var mouse = get_viewport().get_mouse_position()
	var thresholdY = (get_viewport().size.y / 10)*5
	
	var target_pos = reference_poses[current_pose].global_position
	var target_rot = reference_poses[current_pose].global_rotation
	var target_fov = reference_poses[current_pose].fov
	if(mouse.x > 0 && mouse.y > 0 && mouse.x < get_viewport().size.x && mouse.y < get_viewport().size.y):
		if(mouse.y > thresholdY):
			var d = min((mouse.y-thresholdY)/((get_viewport().size.y / 10)*3),1)
			target_pos = reference_poses[0].global_position.lerp(reference_poses[1].global_position,d)
			target_rot = reference_poses[0].global_rotation.lerp(reference_poses[1].global_rotation,d)
			target_fov = lerpf(reference_poses[0].fov, reference_poses[1].fov, d)
		else:
			current_pose = 0
		global_position = lerp(global_position,target_pos,delta*3)
		global_rotation = lerp(global_rotation,target_rot,delta*3)
		fov = lerpf(fov,target_fov,delta*3)
		
		if(mouse.y < get_viewport().size.y/2):
			mouse.y = (get_viewport().size.y/2)+1
		var angle_ray = project_ray_normal(mouse)
		
		
		if(angle_ray.y > -0.45):
			Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
			if(angle_ray.y > 0):
				#angle_ray = Vector3(-angle_ray.x,-0.45,-angle_ray.z)
				return
			else:
				angle_ray = Vector3(angle_ray.x,-0.45,angle_ray.z)
		else:
			Input.mouse_mode = Input.MOUSE_MODE_HIDDEN
			#angle_ray.y *= -1
			#target.global_position = global_position + angle_ray
		
		
		var height_diff = global_position.y - 3.3
		
		var angle_power = height_diff/angle_ray.y
		angle_ray *= angle_power
		target.global_position = (global_position - angle_ray)
		target.position += Vector3(0,0,0.25)
		
	
	pass
	
			
