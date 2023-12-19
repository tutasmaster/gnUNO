extends Node

@export var ip_address : LineEdit
@export var port : LineEdit
@export var nickname : LineEdit
@export var menu : MenuButton
@export var delete: Node3D
@export var player: Node3D

var selectedAppearance = 0

func _ready():
	var m = menu.get_popup()
	m.id_pressed.connect(pressed_button)

func pressed_button(id):
	print(id)
	selectedAppearance = id
	player.set_appearance(id)

func JoinGame():
	GameManager.joinServer(ip_address.text,port.text,nickname.text, selectedAppearance)
	pass
func HostGame():
	GameManager.hostServer(ip_address.text,port.text,nickname.text)
	pass
