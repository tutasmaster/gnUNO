extends Node

@export var pc : PlayerCamera
@export var pc_ragdoll :Camera3D
@export var headTarget : Node3D
@export var area3d : Area3D
@onready var raycast : RayCast3D = $"../Target/RayCast3D"

@export var colorPicker : Node3D

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


func _process(_delta):
	headTarget.global_position = pc.global_position
	headTarget.global_rotation = pc.global_rotation
	pass

var holding = false

func _input(event):
	if get_parent().ragdolled:
		return
	if event is InputEventMouseButton:
		#print("PICKING STUFF UP")
		raycast.set_collision_mask_value(3,false)
		raycast.force_raycast_update()
		var b = raycast.get_collider()
		#for b in area3d.get_overlapping_bodies():
		if(b != null && b.name == "Card" && !b.get_parent().refusesToBePickedUp && event.pressed):
			print("PICKED")
			b.get_parent().requestPickup.rpc_id(1,get_parent().cardTarget.global_position)
		elif(!event.pressed):
			get_parent().drop_object.rpc_id(1,get_parent().cardTarget.global_position)
		else:
			raycast.set_collision_mask_value(3,true)
			raycast.force_raycast_update()
			raycast.set_collision_mask_value(3,false)
			b = raycast.get_collider()
			if(b != null && event.pressed):
				b.execute()
			
			#break
				#else:
					#print("DROPPED")
					#holding = false
					#b.get_parent().requestDrop.rpc_id(1)
			
