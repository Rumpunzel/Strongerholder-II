@icon("uid://bwyi7g5ulk8w0")
class_name MultiplayerSession
extends Session

signal player_connected(peer_id: int, player: SynchronizedPlayer)
signal player_disconnected(peer_id: int)
signal server_disconnected

const PORT: int = 7000
const DEFAULT_SERVER_IP: String = "127.0.0.1" # IPv4 localhost
const MAX_CONNECTIONS: int = 4

const SESSION_SCENE: PackedScene = preload("uid://citi18cutmbiw")

## This contains SynchronizedPlayers for every player, with the keys being each player's unique IDs.
var players: Dictionary[int, SynchronizedPlayer] = { }

var host_player: SynchronizedPlayer

@onready var _players: Node = %SynchronizedPlayers

func _ready() -> void:
	multiplayer.peer_connected.connect(_on_player_connected)
	multiplayer.peer_disconnected.connect(_on_player_disconnected)
	multiplayer.connected_to_server.connect(_on_connected_to_server)
	multiplayer.connection_failed.connect(_on_connection_failed)
	multiplayer.server_disconnected.connect(_on_server_disconnected)

static func create() -> MultiplayerSession:
	return SESSION_SCENE.instantiate()

## Starts the multiplayer session by hosting a game
func start(existing_player: Player) -> Error:
	var server_peer: ENetMultiplayerPeer = ENetMultiplayerPeer.new()
	var error: Error = server_peer.create_server(PORT, MAX_CONNECTIONS)
	if error: return error
	multiplayer.multiplayer_peer = server_peer
	
	if existing_player:
		var host_from_singleplayer: SynchronizedPlayer = SynchronizedPlayer.from_player(existing_player)
		_add_player(host_from_singleplayer)
		host_player = host_from_singleplayer
		existing_player.queue_free()
		print_debug("Using existing player as host!")
	else:
		host_player = _create_player(Game.HOST_ID, get_host_info())
		print_debug("Creating new player to serve as host!")
	started.emit(host_player)
	Toasts.show_toast("Hosted game!", Toasts.Type.SUCCESS)
	print_debug("Started hosting multiplayer game @ %s:%d!" % [MultiplayerSession.DEFAULT_SERVER_IP, MultiplayerSession.PORT])
	return Error.OK

## Stops the multiplayer session
## @returns the host player converted to singleplayer, if session was hosted
## @returns null if leaving a hosted game
func stop() -> Player:
	multiplayer.multiplayer_peer = null
	var host_as_singleplayer: Player = host_player.to_player() if host_player else null
	_remove_all_players()
	stopped.emit(host_as_singleplayer)
	Toasts.show_toast("Left multiplayer!")
	return host_as_singleplayer

func join_game(ip_address: String) -> Error:
	assert(ip_address.is_valid_ip_address())
	var client_peer: ENetMultiplayerPeer = ENetMultiplayerPeer.new()
	var error: Error = client_peer.create_client(ip_address, PORT)
	if error: return error
	multiplayer.multiplayer_peer = client_peer
	Toasts.show_toast("Joined game!", Toasts.Type.SUCCESS)
	print_debug("Joined multiplayer game @ %s:%d!" % [ip_address, MultiplayerSession.PORT])
	return Error.OK

func get_host_info(id: int = Game.HOST_ID) -> Dictionary:
	return { "id": id, "name": player_name, }

@rpc("any_peer", "reliable")
func _register_player(player_info: Dictionary) -> void:
	SynchronizedPlayer.validate_player_info(player_info)
	var player_id: int = multiplayer.get_remote_sender_id()
	if player_id == Game.HOST_ID: return
	_create_player(player_id, player_info)
	print_debug("Player %s registered to multiplayer game!" % player_info)

func _create_player(id: int, player_info: Dictionary) -> SynchronizedPlayer:
	player_info.id = id
	assert(player_info.id == id)
	var new_player: SynchronizedPlayer = SynchronizedPlayer.from_player_info(player_info)
	print_debug("Player %s created for multiplayer game!" % player_info)
	_add_player(new_player)
	return new_player

func _add_player(new_player: SynchronizedPlayer) -> void:
	_players.add_child(new_player, true)
	players[new_player.player_id] = new_player
	player_connected.emit(new_player.player_id, new_player)
	print_debug("Player %s added to multiplayer game!" % new_player.to_player_info())

func _remove_player(player: SynchronizedPlayer) -> void:
	assert(player)
	players.erase(player.player_id)
	_players.remove_child(player)
	player.queue_free()
	print_debug("Removed player %s from the multiplayer game!" % player.to_player_info())

func _remove_all_players(lost_connection: bool = false) -> void:
	for player: SynchronizedPlayer in _players.get_children():
		if not player:
			printerr("Lost connection to host!")
			assert(lost_connection)
			continue
		_remove_player(player)

## When a peer connects, send them the host info.
## This allows transfer of all desired data for each player, not only the unique ID.
func _on_player_connected(id: int) -> void:
	_register_player.rpc_id(id, get_host_info())
	if not id == Game.HOST_ID: Toasts.show_toast("Player joined!", Toasts.Type.SUCCESS)

func _on_player_disconnected(id: int) -> void:
	var disconnected_player: SynchronizedPlayer = _players.get_node_or_null("%d" % id)
	if disconnected_player:
		_remove_player(disconnected_player)
	else:
		printerr("Host disconnected!")
	player_disconnected.emit(id)
	Toasts.show_toast("Played left!")
	print_debug("Player with id %d disconnected from the multiplayer game!" % id)

func _on_connected_to_server() -> void:
	print_debug("Connected to multiplayer server!")

func _on_connection_failed() -> void:
	multiplayer.multiplayer_peer = null
	Toasts.show_toast("Connection failed!", Toasts.Type.ERROR)
	print_debug("Connection failed!")

func _on_server_disconnected() -> void:
	multiplayer.multiplayer_peer = null
	_remove_all_players(true)
	server_disconnected.emit()
	Toasts.show_toast("Server disconnected!", Toasts.Type.ERROR)
	print_debug("Server disconnected!")
