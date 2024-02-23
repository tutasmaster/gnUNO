extends Node3D
@export var mesh_instance : Node3D

var cardUno : Card = null
var card = "B%"
var update = false
var networkId = 0
@export var baseMat : Material
@export var refusesToBePickedUp = false

var updatesTo : Node3D = null

func _ready():
	setCard(card)

@rpc("any_peer")
func requestPickup(pos):
	if(refusesToBePickedUp):
		return
	if(is_multiplayer_authority()):
		#if(updatesTo != null):
			#requestDrop(pos)
			#return
		var id = multiplayer.get_remote_sender_id()
		if(!GameManager.game.canTouchOtherCards && id != networkId):
			return
		for c in GameManager.SCENE_MULTIPLAYER.spawn_object.get_children():
			if(c.name == str(id)):
				if(c.objectPicked != null):
					c.objectPicked.requestDrop(pos)
					break
				print("PICKED SOMETHING FOR ID")
				updatesTo = c.cardTarget
				c.objectPicked = self
				break
				
func requestPickupID(id):
	if(refusesToBePickedUp):
		return
	if(is_multiplayer_authority()):
		#if(updatesTo != null):
			#requestDrop(self.global_position)
			#return
		for c in GameManager.SCENE_MULTIPLAYER.spawn_object.get_children():
			if(c.name == str(id)):
				if(c.objectPicked != null):
					c.objectPicked.requestDrop(c.objectPicked.global_position)
					break
				print("PICKED SOMETHING FOR ID")
				updatesTo = c.cardTarget
				c.objectPicked = self
				break
		
@rpc("any_peer")
func requestDrop(pos):
	if(refusesToBePickedUp):
		return
	if(is_multiplayer_authority()):
		print("DROPPED SOMETHING FOR ID")
		var id = multiplayer.get_remote_sender_id()
		for c in GameManager.SCENE_MULTIPLAYER.spawn_object.get_children():
			if(c.name == str(id)):
				c.objectPicked = null
				break
		updatesTo = null
		global_position = Vector3(pos.x,global_position.y,pos.z)
		var isPlay = Vector2(global_position.x, global_position.z).distance_to(Vector2.ZERO) < 1
		if isPlay:
			GameManager.play(self)
		
@rpc("reliable")
func updateCard(cd):
	set_multiplayer_authority(1)
	card = cd
	setCard(card)

@rpc("reliable")
func delete():
	queue_free()

func _process(_delta):
	if updatesTo != null:
		global_position = Vector3(updatesTo.global_position.x,global_position.y,updatesTo.global_position.z)
		global_rotation = Vector3(updatesTo.global_rotation.x+3.14,updatesTo.global_rotation.y,updatesTo.global_rotation.z)

func setCard(c):
	if(GameManager.cardDictionary.has(c)):
		mesh_instance.set_surface_override_material(0,GameManager.cardDictionary["card"])
	else:
		mesh_instance.set_surface_override_material(0,generateMaterial(c))

func generateMaterial(ca):
	var c = UnoTable.decode_card(ca)
	var x = 0
	var y = 0
	var xS = 1.0/13
	match c.gcolor:
		Card.GColor.RED:
			y = 0
		Card.GColor.BLUE:
			y = 0.20
		Card.GColor.GREEN:
			y = 0.40
		Card.GColor.YELLOW:
			y = 0.60
	match c.value:
		Card.Value.ONE:
			x = 0
		Card.Value.TWO:
			x = xS * 1
		Card.Value.THREE:
			x = xS * 2
		Card.Value.FOUR:
			x = xS * 3
		Card.Value.FIVE:
			x = xS * 4
		Card.Value.SIX:
			x = xS * 5
		Card.Value.SEVEN:
			x = xS * 6
		Card.Value.EIGHT:
			x = xS * 7
		Card.Value.NINE:
			x = xS * 8
		Card.Value.ZERO:
			x = xS * 9
		Card.Value.PLUS_TWO:
			x = xS * 10
		Card.Value.REVERSE:
			x = xS * 11
		Card.Value.STOP:
			x = xS * 12
			
	if(c.value == Card.Value.UNKNOWN):
		x = xS * 3
		y = 0.8025	
	if(c.value == Card.Value.COLOR):
		x = xS * 2
		y = 0.8025
	if(c.value == Card.Value.PLUS_FOUR):
		x = xS * 1
		y = 0.8025
	var mat = baseMat
	mat.uv1_offset = Vector3(x,y,1)
	return mat
