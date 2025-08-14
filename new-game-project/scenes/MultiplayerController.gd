extends Control

@export var address = "127.0.0.1"
@export var port = 4242
var peer: ENetMultiplayerPeer


func _ready() -> void:
	multiplayer.peer_connected.connect(peer_connected)
	multiplayer.peer_disconnected.connect(peer_disconnected)
	multiplayer.connected_to_server.connect(connected_to_server)
	multiplayer.connection_failed.connect(connection_failed)


func _on_host_pressed() -> void:
	peer = ENetMultiplayerPeer.new()
	var error = peer.create_server(port, 2)
	if error != OK:
		print("Cannot host: " + error)
		return
	peer.get_host().compress(ENetConnection.COMPRESS_RANGE_CODER)
	multiplayer.set_multiplayer_peer(peer)
	send_player_information($CenterContainer/VBoxContainer/LineEdit.text, multiplayer.get_unique_id())
	print("Waiting for players")


func _on_join_pressed() -> void:
	peer = ENetMultiplayerPeer.new()
	peer.create_client(address, port)
	peer.get_host().compress(ENetConnection.COMPRESS_RANGE_CODER)
	multiplayer.set_multiplayer_peer(peer)

func _on_start_game_pressed() -> void:
	start_game.rpc()


@rpc("any_peer")
func send_player_information(player_name, id):
	if !GameManager.players.has(id):
		GameManager.players[id] = {
			"name" : player_name,
			"id" : id
		}
	if multiplayer.is_server():
		for i in GameManager.players:
			send_player_information.rpc(GameManager.players[i].name, i)


@rpc("any_peer", "call_local") #decorador
func start_game():
	var scene = load("res://scenes/world.tscn").instantiate()
	get_tree().root.add_child(scene)
	self.hide()


func peer_connected(id):
	print("Player connected " + str(id))
	
func peer_disconnected(id):
	print("Player disconnected " + str(id))
	
func connected_to_server():
	print("Connected to server")
	send_player_information.rpc_id(1, $CenterContainer/VBoxContainer/LineEdit.text, multiplayer.get_unique_id())
	
func connection_failed():
	print("Connection failed")
