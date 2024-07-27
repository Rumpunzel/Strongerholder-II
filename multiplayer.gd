extends Node

signal game_hosted

const PORT := 4433
const HOST_PLAYER_ID := 1

# Called when the node enters the scene tree for the first time.
func _ready() -> void :
	# You can save bandwidth by disabling server relay and peer notifications.
	#multiplayer.server_relay = false
	
	# We only need to add players on the server.
	if not multiplayer.is_server() : return
	# Automatically start the server in headless mode.
	if DisplayServer.get_name() == "headless" :
		print("Automatically starting dedicated server.")
		host_game.call_deferred()

func host_game() -> void :
	# Start as server.
	var peer := ENetMultiplayerPeer.new()
	peer.create_server(PORT)
	if peer.get_connection_status() == MultiplayerPeer.CONNECTION_DISCONNECTED :
		OS.alert("Failed to start multiplayer server.")
		return
	multiplayer.multiplayer_peer = peer
	game_hosted.emit()

func connect_to_game(game_ip_address : String) -> void:
	# Start as client.
	if game_ip_address == "" :
		OS.alert("Need a remote to connect to.")
		return
	
	var peer := ENetMultiplayerPeer.new()
	peer.create_client(game_ip_address, PORT)
	if peer.get_connection_status() == MultiplayerPeer.CONNECTION_DISCONNECTED :
		OS.alert("Failed to start multiplayer client.")
		return
	multiplayer.multiplayer_peer = peer
