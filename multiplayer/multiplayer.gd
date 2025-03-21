class_name Multiplayer
extends Node

signal player_connected(peer_id: int, player_info: Dictionary, player: SynchronizedPlayer)
signal player_disconnected(peer_id: int)
signal server_disconnected

const PORT := 7000
const DEFAULT_SERVER_IP := "127.0.0.1" # IPv4 localhost
const MAX_CONNECTIONS := 4
const HOST_ID := 1

@export var player_scene: PackedScene

# This will contain player info for every player,
# with the keys being each player's unique IDs.
var players: Dictionary[int, Dictionary] = { }

# This is the local player info. This should be modified locally
# before the connection is made. It will be passed to every other peer.
# For example, the value of "name" can be set to something the player
# entered in a UI scene.
var host_info := {
	"name": "Name",
	"player_id": 1,
}

@onready var _players: Node = %SynchronizedPlayers

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
	
	players[HOST_ID] = host_info
	assert(host_info.player_id == HOST_ID)
	_create_player(HOST_ID, host_info)
	return Error.OK

func join_game(ip_address: String) -> Error:
	assert(ip_address.is_valid_ip_address())
	var client_peer := ENetMultiplayerPeer.new()
	var error := client_peer.create_client(ip_address, PORT)
	if error: return error
	multiplayer.multiplayer_peer = client_peer
	return Error.OK

func stop_hosting_game() -> void:
	multiplayer.multiplayer_peer = null
	players.clear()

func leave_game() -> void:
	multiplayer.multiplayer_peer = null
	players.clear()

@rpc("any_peer", "reliable")
func _register_player(new_player_info: Dictionary) -> void:
	var player_id := multiplayer.get_remote_sender_id()
	if player_id == HOST_ID: return
	_create_player(player_id, new_player_info)
	print_debug("Player %s registered to multiplayer game!" % new_player_info)

func _create_player(id: int, player_info: Dictionary) -> SynchronizedPlayer:
	player_info.player_id = id
	players[id] = player_info
	assert(player_info.player_id == id)
	var new_player: SynchronizedPlayer = player_scene.instantiate()
	new_player.player_id = id
	assert(new_player.player_id == id)
	_players.add_child(new_player, true)
	player_connected.emit(id, player_info, new_player)
	print_debug("Player %s created for multiplayer game!" % new_player.name)
	return new_player

# When a peer connects, send them the host info.
# This allows transfer of all desired data for each player, not only the unique ID.
func _on_player_connected(id: int) -> void:
	_register_player.rpc_id(id, host_info)

func _on_player_disconnected(id: int) -> void:
	var disconnected_player := _players.get_node("%d" % id)
	_players.remove_child(disconnected_player)
	disconnected_player.queue_free()
	players.erase(id)
	player_disconnected.emit(id)
	print_debug("Player with id %d disconnected from the multiplayer game!" % id)

func _on_connected_to_server() -> void:
	var peer_id := multiplayer.get_unique_id()
	players[peer_id] = host_info
	player_connected.emit(peer_id, host_info, null)
	print_debug("Connected to multiplayer server!")

func _on_connection_failed() -> void:
	multiplayer.multiplayer_peer = null
	print_debug("Connection failed!")

func _on_server_disconnected() -> void:
	multiplayer.multiplayer_peer = null
	players.clear()
	server_disconnected.emit()
	print_debug("Server disconnected!")
