#ADOPTIONCARDHOLDER REFERS TO THE IDEA THAT THIS CARDHOLDER HAS NO CHILDREN OF ITS OWN
#INSTEAD IT STEALS OTHER OBJECTS AND ADOPTS THEM, IN A WAY WHERE IT'LL HOLD THEM
#BUT IT'S STILL A CHILDLESS OBJECT, AND SHOULD BE TREATED LIKE IT

#is childrenless even a word?

extends Node3D

@export var offset = Vector3(0.1,0.01,0)
@export var maximumOffset = Vector3(0.3,0.01,0)
@export var maxSpace = Vector3(2,0.1,0)
@export var enableSpacing = true
@export var children : Array[Node3D] = []

func _ready():
	set_multiplayer_authority(1)
	updateChildren()
	pass
	
var last_children = 0
#func _process(delta):
	#if(children.size() != last_children):
		#updateChildren()
		#last_children = children.size()
	
func updateChildren():
	
	if(children.size() <= 1):
		for i in children:
			i.global_position = global_position
			i.global_rotation = global_rotation
			return
	
	if enableSpacing:
		var maxOffset = offset * (children.size()-1)
		var midOffset = maxOffset/2
		var step = 0
		for i in children:
			var ro = -midOffset + (offset * step)
			ro = ro.rotated(Vector3.UP, global_rotation.y)
			i.global_position = global_position  + ro
			i.global_rotation = global_rotation
			step += 1
	else:
		offset = maxSpace / (children.size()-1)
		offset = offset.clamp(Vector3.ZERO, maximumOffset)
		var maxOffset = offset * (children.size()-1)
		var midOffset = maxOffset/2
		var step = 0
		for i in children:
			var ro = -midOffset + (offset * step)
			ro = ro.rotated(Vector3.UP, global_rotation.y)
			i.global_position = global_position + ro
			i.global_rotation = global_rotation
			i.rotation = Vector3(i.rotation.x + 3.14,i.rotation.y,0)
			step += 1
		
