extends Control

@export var address = "127.0.0.1"
@export var port = 4242
var peer: ENetMultiplayerPeer
@onready var http: HTTPRequest = $HTTPRequest 

func _ready() -> void:
	multiplayer.peer_connected.connect(peer_connected)
	multiplayer.peer_disconnected.connect(peer_disconnected)
	multiplayer.connected_to_server.connect(connected_to_server)
	multiplayer.connection_failed.connect(connection_failed)
	#local ip
	var ips = IP.get_local_addresses()
	for ip in ips:
		print(ip)


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
	http.request("https://ifconfig.me/all.json")


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


func _on_http_request_request_completed(result: int, response_code: int, headers: PackedStringArray, body: PackedByteArray) -> void:
	print(result)
	print(response_code)
	if response_code == 200:
		print("200")
		#var data = JSON.parse_string(body.get_string_from_utf8())
		#print("Public IP:", data["ip"])
		#print(headers)
		#print("body:", body)
		var response_text = body.get_string_from_utf8()
		#print("Raw response:", response_text)  # Para debug
		var data = JSON.parse_string(response_text)
		#print("Data:", data)
		print(data["ip_addr"])
		print(data["port"])
