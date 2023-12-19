extends Node3D

@export var sync : MultiplayerSynchronizer
@export var spawn_positions : Array[Vector3]
@export var target : Node3D
@export var cardTarget : Node3D
@export var headTarget : Node3D
@export var area3d : Area3D
@export var cardHolder : Node3D
@export var playerModel : MeshInstance3D
@export var playerModelMaterial : Material
@export var playerModelMaterialActive : Material
@export var skeleton : Skeleton3D
@export var appearance_items : Array[Node3D]
@export var audio_stream : AudioStreamPlayer
@export var ragdoll : Node3D
@export var original : Node3D
@export var explosion : AnimatedSprite3D
@export var explosion_sound : AudioStreamPlayer
@export var notify : AudioStreamPlayer
@export var nickname_mesh : MeshInstance3D

var appearance = 0
var nickname = "PLAYER"
var objectPicked : Node3D = null

var localControls = preload("res://Scenes/Client/LocalControls.tscn")

@rpc("any_peer")
func set_nickname(nick):
	nickname = nick
	nickname_mesh.mesh.text = nick

@rpc("any_peer")
func bell_pressed():
	if(!GameManager.is_server):
		audio_stream.play()

@rpc("any_peer")
func set_appearance(id):
	var step = 0
	for a in appearance_items:
		appearance = id
		a.visible = id-1 == step
		
		step+=1

@rpc("any_peer")
func drop_object(pos):
	if objectPicked != null:
		objectPicked.requestDrop(pos)

var isActive = false

@rpc("any_peer")
func set_active_player(isPlayer,coloring):
	if(is_multiplayer_authority()):
		localP.colorPicker.visible = coloring
		if isPlayer && !isActive:
			notify.play()
			isActive = true
		elif !isPlayer:
			isActive = false
	if isPlayer:
		playerModel.set_surface_override_material(0,playerModelMaterialActive)
	else:
		playerModel.set_surface_override_material(0,playerModelMaterial)
	pass

var localP = null

@rpc("any_peer")
func set_pos(pos,rot):
	if(is_multiplayer_authority()):
		global_position = pos
		global_rotation = rot
		localP = localControls.instantiate()
		localP.pc.target = target
		localP.headTarget = headTarget
		localP.area3d = area3d
		add_child(localP)
		set_appearance.rpc(GameManager.app)
		set_nickname.rpc(GameManager.nick)
		#skeleton.set_bone_pose_scale(3,Vector3(0,0,0))

var ragdolled = false

@rpc("any_peer")
func explode():
	explosion.play("default")
	explosion_sound.play()
	ragdoll.sync(skeleton)
	ragdoll.ragdoll()
	ragdoll.visible = true
	original.visible = false
	ragdolled = true
	if(localP != null):
		localP.pc_ragdoll.make_current()
	if(objectPicked != null):
		drop_object(objectPicked.global_position)

@rpc("any_peer")
func reset_player():
	explosion.play("idle")
	ragdoll.reset_ragdoll()
	ragdoll.visible = false
	original.visible = true
	ragdolled = false
	if(localP != null):
		localP.pc.make_current()
	
func _enter_tree():
	set_multiplayer_authority(name.to_int())
	
func _ready():
	for c in get_parent().get_children():
		if(c.name == "H" + name):
			c.global_position = cardHolder.global_position
			c.global_rotation = cardHolder.global_rotation




func _on_animated_sprite_3d_animation_finished():
	explosion.play("idle")
	pass


func _on_animated_sprite_3d_animation_looped():
	explosion.play("idle")
	explosion.stop()
	pass # Replace with function body.
