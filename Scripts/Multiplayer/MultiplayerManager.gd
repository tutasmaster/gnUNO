class_name MultiplayerManager
extends Node

@export var spawn_positions : Array[Node3D]
@export var spawn_order : Array[int]
@export var spawner : MultiplayerSpawner
@export var spawn_object : Node3D
@export var world_manager: Node3D
@export var text: Label

@rpc("unreliable")
func updatePlayerCount(count):
	text.text = str(count) + " players"
	
@rpc("unreliable_ordered")
func announce(ann):
	text.text = ann

func getValidSpawn(pos):
	return spawn_order[pos]
	
func getSpawnFromSeat(pos):
	return spawn_positions[pos]
