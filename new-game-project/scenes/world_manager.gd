extends Node3D

@export var player_scene : PackedScene
var size:int = 5
var bricks: Array[PackedScene] = []
@onready var sync: MultiplayerSynchronizer = $MultiplayerSynchronizer


func _ready() -> void:
	var index = 0
	for i in GameManager.players:
		var current_player = player_scene.instantiate()
		current_player.name = str(GameManager.players[i].id)
		add_child(current_player)
		for spawn in get_tree().get_nodes_in_group("player_spawn_point"):
			if spawn.name == str(index):
				current_player.global_position = spawn.global_position
		index += 1
	
	var my_id = multiplayer.get_unique_id()
	print("my id:", my_id)
	
	bricks.resize(5)
	bricks[0] = preload("res://assets/blocks/bricks_A.gltf")
	bricks[1] = preload("res://assets/blocks/bricks_B.gltf")
	bricks[2] = preload("res://assets/blocks/dirt.gltf")
	bricks[3] = preload("res://assets/blocks/dirt_with_grass.gltf")
	bricks[4] = preload("res://assets/blocks/grass.gltf")
	randomize()
	
	if my_id == 1:
		for i in range(size):
			var n = (randi() % 6) - 1
			create_block.rpc(n, 2, 0, 1, i)
			#var block = bricks[n].instantiate()
			#block.position = Vector3(0,1,i * 2)
			#add_child(block)

@rpc("call_local")
func create_block(type:int, size:int, x:int, y:int, z:int):
	var block = bricks[type].instantiate()
	block.position = Vector3(x * size, y * size, z * size)
	add_child(block)
	pass
