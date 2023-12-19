@tool
extends Node3D

@export var offset = Vector3(0.1,0.01,0)
@export var maximumOffset = Vector3(0.3,0.01,0)
@export var maxSpace = Vector3(2,0.1,0)
@export var enableSpacing = true

func _ready():
	set_multiplayer_authority(1)
	updateChildren()
	pass
	
var last_children = 0
func _process(_delta):
	if(get_children().size() != last_children):
		updateChildren()
		last_children = get_children().size()-1
	
func updateChildren():
	if enableSpacing:
		var maxOffset = offset * (get_children().size()-1)
		var midOffset = maxOffset/2
		var step = 0
		for i in get_children():
			i.position = -midOffset + (offset * step)
			step += 1
	else:
		offset = maxSpace / (get_children().size()-1)
		offset = offset.clamp(Vector3.ZERO, maximumOffset)
		var maxOffset = offset * (get_children().size()-1)
		var midOffset = maxOffset/2
		var step = 0
		for i in get_children():
			i.position = -midOffset + (offset * step)
			step += 1
		
