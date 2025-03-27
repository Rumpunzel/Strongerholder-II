@tool
@icon("uid://bsnfjvi6jpfrm")
class_name PlayerLobby
extends Node

signal game_hosted(ip_address: StringName, port: int)

signal game_joined(host_player_info: Dictionary)
signal player_joined(player: Player)
signal disconnected_from_multiplayer

signal player_name_changed(player_name: String)

const PORT: int = 7000
const DEFAULT_SERVER_IP: StringName = "127.0.0.1" # IPv4 localhost
const MAX_CONNECTIONS: int = 4
const HOST_ID: int = 1

@export_group("Configuration")
@export var _players: Players

func _ready() -> void:
	if Engine.is_editor_hint(): return
	assert(_players)
	multiplayer.multiplayer_peer = null
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
	print_debug("Started hosting multiplayer game @ %s:%d!" % [ip_address, port])
	return Error.OK

func join_game(ip_address: StringName, port: int = PORT) -> Error:
	assert(ip_address.is_valid_ip_address())
	var client_peer: ENetMultiplayerPeer = ENetMultiplayerPeer.new()
	var error: Error = client_peer.create_client(ip_address, port)
	if error: return error
	multiplayer.multiplayer_peer = client_peer
	print_debug("Joined multiplayer game @ %s:%d!" % [ip_address, port])
	return Error.OK

func disconnect_from_multiplayer() -> void:
	disconnected_from_multiplayer.emit()
	multiplayer.multiplayer_peer = null
	print_debug("Disconnected from multiplayer!")

@rpc("any_peer", "reliable")
func _register_player(player_info: Dictionary = Players.get_local_player_info()) -> void:
	Player.validate_player_info(player_info)
	var player_id: int = multiplayer.get_remote_sender_id()
	var new_player: Player = _create_player(player_id, player_info)
	if player_id == HOST_ID:
		game_joined.emit(player_info)
		print_debug("Joined Player %s's multiplayer game!" % player_info)
	else:
		player_joined.emit(new_player)
		print_debug("Player %s joined multiplayer game!" % player_info)

func _create_player(id: int, player_info: Dictionary) -> Player:
	player_info.id = id
	assert(player_info.id == id)
	var new_player: Player = Player.from_player_info(player_info)
	return new_player

## When a peer connects, send them the host info.
## This allows transfer of all desired data for each player, not only the unique ID.
func _on_player_connected(id: int) -> void:
	_register_player.rpc_id(id)

func _on_connected_to_server() -> void:
	print_debug("Connected to multiplayer server!")

func _on_connection_failed() -> void:
	multiplayer.multiplayer_peer = null
	print_debug("Connection failed!")

func _on_server_disconnected() -> void:
	multiplayer.multiplayer_peer = null
	print_debug("Server disconnected!")

func _get_configuration_warnings() -> PackedStringArray:
	var warnings: PackedStringArray = []
	if not _players: warnings.append("Missing Players reference.")
	return warnings
