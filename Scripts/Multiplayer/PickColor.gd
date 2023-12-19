extends Node

@export var color : Card.GColor

	
func execute():
	GameManager.pickColor.rpc_id(1, color)
	pass
