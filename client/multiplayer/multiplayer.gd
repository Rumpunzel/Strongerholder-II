@tool
@icon("uid://djyg1pu0yqd4c")
extends Node

signal game_hosted(ip_address: StringName, port: int)
signal game_joined(host_player_info: Dictionary[StringName, Variant])
signal player_joined(player_info: Dictionary[StringName, Variant])

signal joining_multiplayer
signal connected_to_multiplayer
signal disconnected_from_multiplayer

const PORT: int = 7000
const DEFAULT_SERVER_IP: StringName = "127.0.0.1" # IPv4 localhost
const MAX_CONNECTIONS: int = 4
const HOST_ID: int = 1

func _ready() -> void:
	_go_offline()
	multiplayer.peer_connected.connect(_on_player_connected)
	multiplayer.connected_to_server.connect(_on_connected_to_server)
	multiplayer.connection_failed.connect(_on_connection_failed)
	multiplayer.server_disconnected.connect(_on_server_disconnected)

func host_game(ip_address: StringName = DEFAULT_SERVER_IP, port: int = PORT) -> Error:
	var server_peer: ENetMultiplayerPeer = ENetMultiplayerPeer.new()
	var error: Error = server_peer.create_server(port, MAX_CONNECTIONS)
	if error: return error
	multiplayer.multiplayer_peer = server_peer
	game_hosted.emit(ip_address, port)
	connected_to_multiplayer.emit()
	print_debug("Started hosting multiplayer game @ %s:%d!" % [ip_address, port])
	add_child(Node.new())
	return Error.OK

func join_game(ip_address: StringName, port: int = PORT) -> Error:
	assert(ip_address.is_valid_ip_address())
	var loading_screen_scene: PackedScene = load("uid://dmweuj7kxaxov")
	var loading_screen: CanvasLayer = loading_screen_scene.instantiate()
	add_child(loading_screen)
	joining_multiplayer.emit()
	
	var client_peer: ENetMultiplayerPeer = ENetMultiplayerPeer.new()
	var error: Error = client_peer.create_client(ip_address, port)
	if error: return error
	multiplayer.multiplayer_peer = client_peer
	connected_to_multiplayer.emit()
	loading_screen.queue_free()
	print_debug("Joined multiplayer game @ %s:%d!" % [ip_address, port])
	return Error.OK

func disconnect_from_multiplayer() -> void:
	disconnected_from_multiplayer.emit()
	_go_offline()
	print_debug("Disconnected from multiplayer!")

func is_online() -> bool:
	return not multiplayer.multiplayer_peer is OfflineMultiplayerPeer

@rpc("any_peer", "reliable")
func _register_player(player_info: Dictionary[StringName, Variant]) -> void:
	Player.validate_player_info(player_info)
	var peer_id: int = multiplayer.get_remote_sender_id() if is_online() else HOST_ID
	player_info[Player.ID] = peer_id
	if peer_id == HOST_ID:
		game_joined.emit(player_info)
		connected_to_multiplayer.emit()
		print_debug("Joined Player %s's multiplayer game!" % player_info)
	else:
		player_joined.emit(player_info)
		print_debug("Player %s joined multiplayer game!" % player_info)

func _go_offline() -> void:
	var offline_peer: OfflineMultiplayerPeer = OfflineMultiplayerPeer.new()
	multiplayer.multiplayer_peer = offline_peer

## When a peer connects, send them the host info.
## This allows transfer of all desired data for each player, not only the unique ID.
func _on_player_connected(peer_id: int) -> void:
	var host_player_info: Dictionary[StringName, Variant] = Player.get_local_player_info()
	_register_player.rpc_id(peer_id, host_player_info)

func _on_connected_to_server() -> void:
	print_debug("Connected to multiplayer server!")

func _on_connection_failed() -> void:
	_go_offline()
	print_debug("Connection failed!")

func _on_server_disconnected() -> void:
	_go_offline()
	print_debug("Server disconnected!")
