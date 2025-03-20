extends Node

signal game_hosted
signal game_joined

signal player_connected(peer_id: int)
signal player_disconnected(peer_id: int)
signal server_disconnected

const PORT := 7000
const DEFAULT_SERVER_IP := "127.0.0.1" # IPv4 localhost
const MAX_CONNECTIONS := 4

# This will contain player info for every player,
# with the keys being each player's unique IDs.
var players: Dictionary[int, int] = { }

# This is the local player info. This should be modified locally
# before the connection is made. It will be passed to every other peer.
# For example, the value of "name" can be set to something the player
# entered in a UI scene.
var host_id := 1
var host_info := host_id

var players_loaded := 0


func _ready() -> void:
	multiplayer.peer_connected.connect(_on_player_connected)
	multiplayer.peer_disconnected.connect(_on_player_disconnected)
	multiplayer.connected_to_server.connect(_on_connected_to_server)
	multiplayer.connection_failed.connect(_on_connection_failed)
	multiplayer.server_disconnected.connect(_on_server_disconnected)


func host_game() -> Error:
	var server_peer := ENetMultiplayerPeer.new()
	var error := server_peer.create_server(PORT, MAX_CONNECTIONS)
	if error: return error
	multiplayer.multiplayer_peer = server_peer
	game_hosted.emit()
	
	players[host_id] = host_info
	assert(host_id == host_info)
	player_connected.emit(host_id, host_info)
	print_debug("Started hosting multiplayer game!")
	return Error.OK

func join_game(ip_address: String) -> Error:
	assert(ip_address.is_valid_ip_address())
	var client_peer := ENetMultiplayerPeer.new()
	var error := client_peer.create_client(ip_address, PORT)
	if error: return error
	multiplayer.multiplayer_peer = client_peer
	game_joined.emit()
	print_debug("Joined multiplayer game!")
	return Error.OK

func leave_multiplayer() -> void:
	multiplayer.multiplayer_peer = null
	players.clear()
	print_debug("Left multiplayer game!")

# When the server decides to start the game from a UI scene, do Multiplayer.load_game.rpc(filepath)
@rpc("call_local", "reliable")
func load_game(game_scene_path: String):
	get_tree().change_scene_to_file(game_scene_path)

# Every peer will call this when they have loaded the game scene.
@rpc("any_peer", "call_local", "reliable")
func player_loaded():
	if not multiplayer.is_server(): return
	players_loaded += 1
	if players_loaded == players.size():
		#Game.start_game()
		players_loaded = 0


@rpc("any_peer", "reliable")
func _register_player(player_info: int) -> void:
	var player_id := multiplayer.get_remote_sender_id()
	player_info = player_id
	players[player_id] = player_info
	assert(player_id == player_info)
	player_connected.emit(player_id, player_info)
	print_debug("Player %s registered to multiplayer game!" % player_info)

# When a peer connects, send them the host info.
# This allows transfer of all desired data for each player, not only the unique ID.
func _on_player_connected(id: int) -> void:
	_register_player.rpc_id(id, host_info)

func _on_player_disconnected(id: int) -> void:
	players.erase(id)
	player_disconnected.emit(id)
	print_debug("Player with id %d disconnected from the multiplayer game!" % id)

func _on_connected_to_server() -> void:
	var peer_id := multiplayer.get_unique_id()
	players[peer_id] = host_info
	player_connected.emit(peer_id, host_info)
	print_debug("Connected to multiplayer server!")

func _on_connection_failed() -> void:
	multiplayer.multiplayer_peer = null
	print_debug("Connection failed!")

func _on_server_disconnected() -> void:
	multiplayer.multiplayer_peer = null
	players.clear()
	server_disconnected.emit()
	print_debug("Server disconnected!")
