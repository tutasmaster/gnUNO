#This is a card requester
#...it requests cards

extends StaticBody3D

@rpc("any_peer")
func request_card():
	if(is_multiplayer_authority()):
		var id = multiplayer.get_remote_sender_id()
		GameManager.drawCardForPlayer(id)

func execute():
	request_card.rpc_id(1)

func _ready():
	set_multiplayer_authority(1)
