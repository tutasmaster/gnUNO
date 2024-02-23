extends Node

@export var networking = false
@export var connected_to_server = false
@export var is_server = false

@export var game : UnoTable = null

var SCENE_MULTIPLAYER = null
var SCENE_MAIN_MENU = null

@export var CARD_PREFAB = preload("res://Scenes/Client/Card.tscn")

@export var cardDictionary = {}

@export var playerList : Array[LocalPlayer] = []

var clientPlayerObject = null

func _ready():
	SCENE_MAIN_MENU = load("res://Scenes/MainMenu.tscn").instantiate()
	get_tree().root.add_child.call_deferred(SCENE_MAIN_MENU)
	SCENE_MAIN_MENU.name = "MM"
	print(SCENE_MAIN_MENU)
	multiplayer.peer_connected.connect(_peer_connected)
	multiplayer.peer_disconnected.connect(_peer_disconnected)
	multiplayer.server_disconnected.connect(_server_disconnected)
	multiplayer.connection_failed.connect(_connection_failed)
	multiplayer.connected_to_server.connect(_connected_to_server)
	pass

func startGame():
	game.startGame()
	resetPlayers()
	syncHands()
	syncTable()
	
func resetPlayers():
	for p in game.players:
		p.playerObject.reset_player.rpc()
	pass
	
func resetHands(id):
	var step = 0
	for p in game.players:
		if p.networkId == id:
			for c in p.hand.card_arr:
				if(c.object != null):
					SCENE_MULTIPLAYER.spawn_object.remove_child(c.object)
					c.object.delete()
					step-=1
			step+=1
	step = 0
		
	for p in game.players:
		if(p.networkId == id):
			p.playerObject.cardHolder.children.clear()
			for c in p.hand.card_arr:
				var card = CARD_PREFAB.instantiate()
				card.card = UnoTable.encode_card(c)
				card.cardUno = c
				card.networkId = id
				c.object = card
				SCENE_MULTIPLAYER.spawn_object.add_child(card, true)
				p.playerObject.cardHolder.children.push_back(card)
				#card.updateCard.rpc(card.card)
				#p.handObject.cardHolder.add_child(card, true)
			p.playerObject.cardHolder.updateChildren()
			step += 1
		syncHands(id)
	
func syncHands(id = null):
	#SCENE_MULTIPLAYER.world_manager.card.updateCard.rpc(game.encode_card(game.discard.top()))
	if(id == null):
		var step = 0
		for c in SCENE_MULTIPLAYER.spawn_object.get_children().size():
			if SCENE_MULTIPLAYER.spawn_object.get_children()[step].name.begins_with("Card"):
				var ch = SCENE_MULTIPLAYER.spawn_object.get_children()[step]
				SCENE_MULTIPLAYER.spawn_object.remove_child(ch)
				ch.delete()
				step-=1
			step+=1
			
		step = 0
		
		for p in game.players:
			p.playerObject.cardHolder.children.clear()
			for c in p.hand.card_arr:
				var card = CARD_PREFAB.instantiate()
				card.card = UnoTable.encode_card(c)
				card.cardUno = c
				card.networkId = p.networkId
				c.object = card
				SCENE_MULTIPLAYER.spawn_object.add_child(card, true)
				p.playerObject.cardHolder.children.push_back(card)
				#card.updateCard.rpc(card.card)
				#p.handObject.cardHolder.add_child(card, true)
			p.playerObject.cardHolder.updateChildren()
			step += 1
		for p in game.players:
			syncHands(p.networkId)
	else:
		for p in game.players:
			for c in p.hand.card_arr:
				if(p.playerObject.name != str(id) && game.isHiddenCards == true):
					c.object.updateCard.rpc_id(id,"B%")
				else:
					c.object.updateCard.rpc_id(id,c.object.card)

func syncTable(id = null):
	
	if(game.state != UnoTable.STATE.LOBBY && game.state != UnoTable.STATE.END):
		if(game.state == UnoTable.STATE.HOLD && game.isHold(UnoTable.HOLD_STATE.STACKING)):
			SCENE_MULTIPLAYER.announce.rpc("DRAW " + str(game.draw_count) + "/" + str(game.stack))
		elif(game.state == UnoTable.STATE.HOLD && game.isHold(UnoTable.HOLD_STATE.COLORING)):
			SCENE_MULTIPLAYER.announce.rpc("PICK A COLOR")
		else:
			SCENE_MULTIPLAYER.announce.rpc("")
			
		match game.current_color:
			Card.GColor.RED:
				SCENE_MULTIPLAYER.world_manager.light.light_color = Color(1,0.2,0.2)
				#SCENE_MULTIPLAYER.world_manager.bulb.get_surface_override_material()
				var m : StandardMaterial3D = SCENE_MULTIPLAYER.world_manager.bulb.get_surface_override_material(0)
				m.emission = Color(1,0,0)
				SCENE_MULTIPLAYER.world_manager.bulb.set_surface_override_material(0,m)
			Card.GColor.BLUE:
				SCENE_MULTIPLAYER.world_manager.light.light_color = Color(0.2,0.5,1)
				var m : StandardMaterial3D = SCENE_MULTIPLAYER.world_manager.bulb.get_surface_override_material(0)
				m.emission = Color(0,0,1)
				SCENE_MULTIPLAYER.world_manager.bulb.set_surface_override_material(0,m)
			Card.GColor.GREEN:
				SCENE_MULTIPLAYER.world_manager.light.light_color = Color(0.2,1,0.2)
				var m : StandardMaterial3D = SCENE_MULTIPLAYER.world_manager.bulb.get_surface_override_material(0)
				m.emission = Color(0,1,0)
				SCENE_MULTIPLAYER.world_manager.bulb.set_surface_override_material(0,m)
			Card.GColor.YELLOW:
				SCENE_MULTIPLAYER.world_manager.light.light_color = Color(1,1.0,0.0)
				var m : StandardMaterial3D = SCENE_MULTIPLAYER.world_manager.bulb.get_surface_override_material(0)
				m.emission = Color(1,1,0)
				SCENE_MULTIPLAYER.world_manager.bulb.set_surface_override_material(0,m)
			Card.GColor.ANY:
				SCENE_MULTIPLAYER.world_manager.light.light_color = Color(1,1,1)
				var m : StandardMaterial3D = SCENE_MULTIPLAYER.world_manager.bulb.get_surface_override_material(0)
				m.emission = Color(1,1,1)
				SCENE_MULTIPLAYER.world_manager.bulb.set_surface_override_material(0,m)
		if(id == null):
			SCENE_MULTIPLAYER.world_manager.card.updateCard.rpc(game.encode_card(game.discard.top()))
		else:
			SCENE_MULTIPLAYER.world_manager.card.updateCard.rpc_id(id,game.encode_card(game.discard.top()))
		var step = 0
		for p in game.players:
			if p.force_update == true:
				resetHands(p.networkId)
				p.force_update = false
			if(id == null):
				p.playerObject.set_active_player.rpc(
					game.current_player == step,
					(game.state == UnoTable.STATE.HOLD && game.current_player == step && game.isHold(UnoTable.HOLD_STATE.COLORING))
				)
			else:
				p.playerObject.set_active_player.rpc_id(
					id,
					game.current_player == step,
					(game.state == UnoTable.STATE.HOLD && get_current_player().networkId == id && game.isHold(UnoTable.HOLD_STATE.COLORING))
				)
			step+=1
	elif(game.state == UnoTable.STATE.END):
		for p in game.players:
			if !p.victory:
				p.playerObject.explode.rpc()

func get_current_player():
	return game.players[game.current_player]

func play(card):
	for p in game.players:
		if p.networkId == multiplayer.get_remote_sender_id():
			if(card.networkId != get_current_player().networkId && !game.isPlayOtherCards):
				placeCard(card)
				return
			var _cardCount = p.hand.card_arr.size()
			var _c = p.hand.remove_card(card.cardUno)
			var ca = game.play(card.cardUno)
			if ca != null:
				p.hand.insert(ca)
			else:
				SCENE_MULTIPLAYER.spawn_object.remove_child(card)
				card.delete()
			syncTable()
			
			return
		else:
			placeCard(card)
	
func placeCard(card):
	var v1 = Vector2(card.global_position.x, card.global_position.z)
	for p in game.players:
		if p.networkId == card.networkId:
			var v2 = Vector2(p.playerObject.global_position.x, p.playerObject.global_position.z)
			var v3 = (v2 - v1).normalized() * 1.25
			card.global_position = Vector3(v3.x, card.global_position.y, v3.y)
			return

	#syncHands()
var app = 0
var nick = "PLAYER"
func joinServer(ip,port,nickname="PLAYER", appearance = 0):
	app = appearance
	nick = nickname
	if(connected_to_server):
		print("WON'T JOIN A SERVER WHILE CURRENTLY CONNECTED")
		return
	var peer = ENetMultiplayerPeer.new()
	peer.create_client(ip,int(port))
	if peer.get_connection_status() == MultiplayerPeer.CONNECTION_DISCONNECTED:
		print("FAILED TO START CLIENT")
		return
	else:
		print("JOINED " + ip + ":" + port)
		multiplayer.multiplayer_peer = peer
		networking = true

var settings_scene = null

func hostServer(_ip,port,_nickname="PLAYER"):
	if(connected_to_server):
		print("WON'T JOIN A SERVER WHILE CURRENTLY CONNECTED")
		return
	var peer = ENetMultiplayerPeer.new()
	peer.create_server(int(port));
	game = UnoTable.new()
	if peer.get_connection_status() == MultiplayerPeer.CONNECTION_DISCONNECTED:
		print("FAILED TO START SERVER")
	else:
		is_server = true
		print("STARTED A SERVER")
		multiplayer.multiplayer_peer = peer;
		networking = true
		SCENE_MULTIPLAYER = load("res://Scenes/Multiplayer.tscn").instantiate()
		get_tree().root.add_child(SCENE_MULTIPLAYER)
		var s = load("res://Scenes/ServerSettings.tscn").instantiate()
		get_tree().root.add_child(s)
		settings_scene = s
		if(SCENE_MAIN_MENU != null):
			SCENE_MAIN_MENU.queue_free()
		#spawnCards()
		return

func _peer_connected(id):
	print("PEER CONNECTED " + str(id))
	if(id == 1):
		connected_to_server = true
	if(is_server):
		spawn_player(id)
		SCENE_MULTIPLAYER.updatePlayerCount.rpc(game.players.size())
		settings_scene.setPlayerCount(game.players.size())
	pass

func checkValidSeats(player):
	for i in range(0,8):
		var foundP = false
		for p in game.players:
			if p.seat == SCENE_MULTIPLAYER.getValidSpawn(i):
				foundP = true
				break
		if(!foundP):
			player.seat = SCENE_MULTIPLAYER.getValidSpawn(i)
			return 	SCENE_MULTIPLAYER.getSpawnFromSeat(player.seat)			
	return null

var volume = 0

func updateVolume(v):
	volume = v
	if v < -48:
		volume = -1000
	for p in playerList:
		if p != null:
			if(p.audio_stream != null):
				p.audio_stream.set_volume_db((volume))
			if(p.explosion_sound != null):
				p.explosion_sound.set_volume_db((volume))
			if(p.notify != null):
				p.notify.set_volume_db((volume))

func spawn_player(id):
	var player = load("res://Scenes/Client/Player.tscn").instantiate()
	player.name = str(id)
	SCENE_MULTIPLAYER.spawn_object.add_child(player,true)
	var holder = load("res://Scenes/Client/CardSpawner.tscn").instantiate()
	holder.name = "H"+str(id)
	SCENE_MULTIPLAYER.spawn_object.add_child(holder,true)
	var unoPlayer = UnoPlayer.new()
	var s = checkValidSeats(unoPlayer)
	if(s == null):
		multiplayer.multiplayer_peer.disconnect_peer(id, true)
		return
	player.set_pos.rpc(s.global_position, s.global_rotation)
	unoPlayer.playerObject = player
	unoPlayer.handObject = holder
	unoPlayer.networkId = id
	game.players.push_back(unoPlayer)
	syncTable(id)
	syncHands(id)
	for p in game.players:
		p.playerObject.set_appearance.rpc_id(id,p.playerObject.appearance)
		p.playerObject.set_nickname.rpc_id(id,p.playerObject.nickname)
	
#func sync_player(id):
	#for h in SCENE_MULTIPLAYER.world_manager.hands:
		#for c in h.get_children():
			#c.updateCard.rpc_id(id,c.card)
	
func _peer_disconnected(id):
	print("PEER DISCONNECTED " + str(id))
	if(id == 1):
		connected_to_server = false
		return
	if(is_multiplayer_authority()):
		var step = 0
		for p in game.players:
			if(p.networkId == id):
				p.playerObject.queue_free()
				game.players.remove_at(step)
				break
			step+=1
		syncTable()
		syncHands()
		settings_scene.setPlayerCount(game.players.size())
	pass
	
func _server_disconnected():
	print("SERVER DISCONNECTED")
	networking = false
	multiplayer.multiplayer_peer = null
	connected_to_server = false
	if(SCENE_MULTIPLAYER != null):
		SCENE_MULTIPLAYER.queue_free()
	
	SCENE_MAIN_MENU = load("res://Scenes/MainMenu.tscn").instantiate()
	get_tree().root.add_child.call_deferred(SCENE_MAIN_MENU)
	SCENE_MAIN_MENU.name = "MM"
	print(SCENE_MAIN_MENU)
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	get_tree().reload_current_scene()
	pass
	
func _connection_failed():
	print("CONNECTION FAILED")
	networking = false
	connected_to_server = false
	if(SCENE_MULTIPLAYER != null):
		SCENE_MULTIPLAYER.queue_free()
	pass


func _connected_to_server():
	print("CONNECTED TO SERVER")
	networking = true
	connected_to_server = true
	if(SCENE_MAIN_MENU != null):
		SCENE_MAIN_MENU.queue_free()
	SCENE_MULTIPLAYER = load("res://Scenes/Multiplayer.tscn").instantiate()
	get_tree().root.add_child(SCENE_MULTIPLAYER)
	
func drawCardForPlayer(id):
	var step = 0
	for p in game.players:
		if(p.playerObject.name == str(id)):
			var c = game.drawCard(id)
			if(c == null):
				return
			p.hand.insert(c)
			p.called_himself = false
			
			var card = CARD_PREFAB.instantiate()
			card.card = UnoTable.encode_card(c)
			card.cardUno = c
			c.object = card
			SCENE_MULTIPLAYER.spawn_object.add_child(card, true)
			p.playerObject.cardHolder.children.push_back(card)
			card.global_position = Vector3(card.global_position.x, 3.3, card.global_position.y)
			for p1 in game.players:
				if p1.networkId != p.networkId && game.isHiddenCards == true:
					card.updateCard.rpc_id(p1.networkId, "B%")
				else:
					card.updateCard.rpc_id(p1.networkId, card.card)
			card.requestPickupID(id)
			game.draw(step)
			
			break
		step += 1
	syncTable()
	#resetHands(id)
	
@rpc("any_peer")
func pickColor(color):
	var step = 0
	for p in game.players:
		if p.networkId == multiplayer.get_remote_sender_id():
			break
		step+=1
	game.pickColor(color,step)
	syncTable()
	pass
	
@rpc("any_peer")
func uno():
	if is_server:
		print("Player has tried to call UNO")
		if multiplayer.get_remote_sender_id() == get_current_player().networkId:
			game.callUno()
			print("Player HAS called UNO")
	
func spawnCards():
	var step = 0
	for i in game.players:
		for c in i.hand.card_arr:
			var card = CARD_PREFAB.instantiate()
			card.card = UnoTable.encode_card(c)
			SCENE_MULTIPLAYER.world_manager.hands[step].add_child(card, true)
		SCENE_MULTIPLAYER.world_manager.hands[step].updateChildren()
		step += 1
	pass
	#for i in range(8):
		#var card = CARD_PREFAB.instantiate()
		#card.position = Vector3(i * 0.6,3.3 + i * 0.01,0)
		#card.card = "B" + str(i+1)
		#SCENE_MULTIPLAYER.spawn_object.add_child(card, true)
