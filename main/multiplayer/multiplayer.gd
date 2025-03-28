@tool
@icon("uid://djyg1pu0yqd4c")
class_name Multiplayer
extends Node

signal game_hosted(ip_address: StringName, port: int)
signal game_joined(host_player_info: Dictionary)
signal player_joined(player: Player)
signal disconnected_from_multiplayer

const PORT: int = 7000
const DEFAULT_SERVER_IP: StringName = "127.0.0.1" # IPv4 localhost
const MAX_CONNECTIONS: int = 4
const HOST_ID: int = 1

@export_group("Configuration")
@export var _multiplayer_lobby: MultiplayerLobby

@onready var _main: MainNode = Main

func _ready() -> void:
	if Engine.is_editor_hint(): return
	assert(_multiplayer_lobby)
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
	add_child(Node.new())
	return Error.OK

func join_game(ip_address: StringName, port: int = PORT) -> Error:
	assert(ip_address.is_valid_ip_address())
	_multiplayer_lobby.remove_local_player()
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

static func validate_registering_player_info(player_info: Dictionary[StringName, Variant]) -> void:
	assert(player_info.has_all([Player.NAME, Player.GHOST_SPRITE_FRAME]))
	assert(player_info.size() == 2)

@rpc("any_peer", "reliable")
func _register_player(registering_player_info: Dictionary[StringName, Variant]) -> void:
	validate_registering_player_info(registering_player_info)
	var peer_id: int = multiplayer.get_remote_sender_id() if multiplayer.multiplayer_peer else HOST_ID
	var player_info: Dictionary[StringName, Variant] = _create_player_info(peer_id, registering_player_info)
	if peer_id == HOST_ID:
		game_joined.emit(player_info)
		print_debug("Joined Player %s's multiplayer game!" % player_info)
	else:
		var player: Player = Player.from_player_info(player_info)
		player_joined.emit(player)
		print_debug("Player %s joined multiplayer game!" % player_info)

func _create_registering_player_info(player_name: String = _main.local_player_name, ghost_sprite_frame: int = _main.local_ghost_sprite_frame) -> Dictionary[StringName, Variant]:
	var registering_player_info: Dictionary[StringName, Variant] = {
		Player.NAME: player_name,
		Player.GHOST_SPRITE_FRAME: ghost_sprite_frame,
	}
	validate_registering_player_info(registering_player_info)
	return registering_player_info

func _create_player_info(peer_id: int, registering_player_info: Dictionary[StringName, Variant]) -> Dictionary[StringName, Variant]:
	validate_registering_player_info(registering_player_info)
	var player_info: Dictionary[StringName, Variant] = registering_player_info
	player_info[Player.ID] = peer_id
	assert(player_info[Player.ID] == peer_id)
	Player.validate_player_info(player_info)
	return player_info

## When a peer connects, send them the host info.
## This allows transfer of all desired data for each player, not only the unique ID.
func _on_player_connected(peer_id: int) -> void:
	_register_player.rpc_id(peer_id, _create_registering_player_info())

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
	if not _multiplayer_lobby: warnings.append("Missing MultiplayerLobby reference.")
	return warnings
