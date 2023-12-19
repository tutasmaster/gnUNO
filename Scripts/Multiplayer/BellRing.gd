extends Node3D

	
func execute():
	get_parent().get_parent().bell_pressed.rpc()
	get_parent().get_parent().bell_pressed()
	GameManager.uno.rpc_id(1)
	pass
