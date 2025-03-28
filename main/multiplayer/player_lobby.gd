@tool
@icon("uid://bsnfjvi6jpfrm")
class_name PlayerLobby
extends Node

signal local_player_name_changed(player_name: String)

signal game_hosted(ip_address: StringName, port: int)
signal game_joined(host_player_info: Dictionary)
signal player_joined(player: Player)
signal disconnected_from_multiplayer

const PORT: int = 7000
const DEFAULT_SERVER_IP: StringName = "127.0.0.1" # IPv4 localhost
const MAX_CONNECTIONS: int = 4
const HOST_ID: int = 1

const CONFIG_FILE_PATH: StringName = "res://config_multiplayer.cfg" # "user://config_multiplayer.cfg"

const _PLAYER_SECTION: StringName = "player"

@export_group("Configuration")
@export var _players: Players

func _ready() -> void:
	if Engine.is_editor_hint(): return
	_load_config()
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
	add_child(Node.new())
	return Error.OK

func join_game(ip_address: StringName, port: int = PORT) -> Error:
	assert(ip_address.is_valid_ip_address())
	#_unspawn_everything()
	var client_peer: ENetMultiplayerPeer = ENetMultiplayerPeer.new()
	var error: Error = client_peer.create_client(ip_address, port)
	if error: return error
	multiplayer.multiplayer_peer = client_peer
	print_debug("Joined multiplayer game @ %s:%d!" % [ip_address, port])
	return Error.OK

func _unspawn_everything() -> void:
	get_tree().call_group("Spawners", "remove_all_spawned_nodes")

func disconnect_from_multiplayer() -> void:
	disconnected_from_multiplayer.emit()
	multiplayer.multiplayer_peer = null
	print_debug("Disconnected from multiplayer!")

@rpc("any_peer", "reliable")
func _register_player(player_info: Dictionary) -> void:
	Player.validate_player_info(player_info)
	print("player registering with this player_info: %s" % player_info)
	var player_id: int = multiplayer.get_remote_sender_id()
	print("player_id: %d" % player_id)
	var new_player: Player = _create_player(player_id, player_info)
	if player_id == HOST_ID:
		game_joined.emit(player_info)
		print_debug("Joined Player %s's multiplayer game!" % player_info)
	else:
		player_joined.emit(new_player)
		print_debug("Player %s joined multiplayer game!" % player_info)

func _create_player(peer_id: int, player_info: Dictionary) -> Player:
	player_info[Player.ID] = peer_id
	assert(player_info[Player.ID] == peer_id)
	var new_player: Player = Player.from_player_info(player_info)
	return new_player

func _update_config_file() -> Error:
	var config: ConfigFile = ConfigFile.new()
	var local_player_info: Dictionary[StringName, Variant] = _players.local_player.get_player_info()
	var player_name: String = local_player_info[Player.NAME]
	config.set_value(_PLAYER_SECTION, "player_name", player_name)
	# Save it to a file (overwrite if already exists).
	var error: Error = config.save(CONFIG_FILE_PATH)
	if error == OK: print_debug("Saved multiplayer config!")
	else: printerr("Could not save multiplayer config file due to Error %s" % error)
	return error

func _load_config() -> Error:
	if not FileAccess.file_exists(CONFIG_FILE_PATH):
		print_debug("No multiplayer config file found, creating default!")
		var default_config: ConfigFile = ConfigFile.new()
		var default_error: Error = default_config.save(CONFIG_FILE_PATH)
		if default_error == OK: print_debug("Saved default multiplayer config!")
		else:
			printerr("Could not save default multiplayer config file due to Error %s" % default_error)
			return default_error
	var config: ConfigFile = ConfigFile.new()
	var player_name: String = ""
	# Load data from a file.
	var error: Error = config.load(CONFIG_FILE_PATH)
	# If the file didn't load, ignore it.
	if error == OK:
		player_name = config.get_value(_PLAYER_SECTION, "player_name", player_name)
		print_debug("Loaded multiplayer config!")
	else: printerr("Could not load multiplayer config file due to Error %s" % error)
	_players.create_local_player(HOST_ID, player_name)
	local_player_name_changed.emit(player_name)
	return error

func _on_player_name_change_requested(player_name: String) -> void:
	_players.change_name_for_local_player(player_name)

func _on_host_player_info_changed(host_player_info: Dictionary[StringName, Variant]) -> void:
	Player.validate_player_info(host_player_info)
	_update_config_file()

## When a peer connects, send them the host info.
## This allows transfer of all desired data for each player, not only the unique ID.
func _on_player_connected(peer_id: int) -> void:
	_register_player.rpc_id(peer_id, _players.local_player.get_player_info())

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
