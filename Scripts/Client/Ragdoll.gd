extends Node3D

@export var legman : Skeleton3D
@export var hip_bone : PhysicalBone3D

func reset_ragdoll():
	hip_bone.linear_velocity = Vector3.ZERO
	hip_bone.angular_velocity = Vector3.ZERO
	legman.physical_bones_stop_simulation()

func ragdoll():
	legman.physical_bones_start_simulation()
	#hip_bone.apply_central_impulse(Vector3((hip_bone.global_position.x * 50) + randf_range(-50,50),randf_range(-50,50),(hip_bone.global_position.z * 50) + randf_range(-50,50)))

func sync_bone(node, bone_id):
	legman.set_bone_pose_position(bone_id, node.get_bone_pose_position(bone_id))
	legman.set_bone_pose_rotation(bone_id, node.get_bone_pose_rotation(bone_id))
	legman.set_bone_pose_scale(bone_id, node.get_bone_pose_scale(bone_id))
	for b in legman.get_bone_children(bone_id):
		sync_bone(node, b)

func sync(node):
	sync_bone(node, 0)
	for n in node.get_children():
		for c in legman.get_children():
			if c.name == n.name:
				c.visible = n.visible
				break

