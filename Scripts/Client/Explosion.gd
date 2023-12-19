extends StaticBody3D


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

var d = 0
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	d += delta
	var s = d
	position = Vector3(position.x, position.y + delta * 30, position.z)
	pass
