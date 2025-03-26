@tool
@icon("uid://bsnfjvi6jpfrm")
extends Node

signal multiplayer_started
signal multiplayer_stopped

signal game_joined(host_player_info: Dictionary)
signal player_joined(player: Player)

signal player_connected(peer_id: int, player: Player)
## [param player] may be null if the host disconnected
signal player_disconnected(peer_id: int, player: Player)
signal server_disconnected

@export_group("Configuration")
@export var _player_spawner: Node

## This contains [Player]s for every player, with the keys being each player's unique IDs.
var _players: Dictionary[int, Player] = { }
var _host_player: Player

func _ready() -> void:
	if Engine.is_editor_hint(): return
	multiplayer.peer_connected.connect(_on_player_connected)
	multiplayer.peer_disconnected.connect(_on_player_disconnected)
	multiplayer.connected_to_server.connect(_on_connected_to_server)
	multiplayer.connection_failed.connect(_on_connection_failed)
	multiplayer.server_disconnected.connect(_on_server_disconnected)
	
	Game.player_name_changed.connect(_on_player_name_changed)
	Game.game_hosted.connect(host_game)
	Game.game_joined.connect(join_game)
	Game.stopped_hosting_game.connect(stop_hosting)
	
	player_connected.connect(Game.player_connected.emit)
	player_disconnected.connect(Game.player_disconnected.emit)
	server_disconnected.connect(Game.leave_game)
	
	_host_player = _create_player(Game.HOST_ID, get_host_info())

func host_game(ip_address: StringName, port: int) -> Error:
	var server_peer: ENetMultiplayerPeer = ENetMultiplayerPeer.new()
	var error: Error = server_peer.create_server(port, Game.MAX_CONNECTIONS)
	if error: return error
	multiplayer.multiplayer_peer = server_peer
	multiplayer_started.emit(_host_player)
	print_debug("Started hosting multiplayer game @ %s:%d!" % [ip_address, port])
	return Error.OK

func stop_hosting() -> void:
	multiplayer.multiplayer_peer = null
	_remove_all_players()
	multiplayer_stopped.emit()
	print_debug("Stopped hosting multiplayer game!")

func join_game(ip_address: StringName, port: int) -> Error:
	assert(ip_address.is_valid_ip_address())
	var client_peer: ENetMultiplayerPeer = ENetMultiplayerPeer.new()
	var error: Error = client_peer.create_client(ip_address, port)
	if error: return error
	multiplayer.multiplayer_peer = client_peer
	print_debug("Joined multiplayer game @ %s:%d!" % [ip_address, port])
	return Error.OK

func get_host_info(id: int = Game.HOST_ID) -> Dictionary:
	return { "id": id, "name": Game.player_name }

@rpc("any_peer", "reliable")
func _register_player(player_info: Dictionary = get_host_info()) -> void:
	Player.validate_player_info(player_info)
	var player_id: int = multiplayer.get_remote_sender_id()
	if player_id == Game.HOST_ID:
		game_joined.emit(player_info)
		print_debug("Joined Player %s's multiplayer game!" % player_info)
	else:
		var new_player: Player = _create_player(player_id, player_info)
		player_joined.emit(new_player)
		print_debug("Player %s joined multiplayer game!" % player_info)

func _create_player(id: int, player_info: Dictionary) -> Player:
	player_info.id = id
	assert(player_info.id == id)
	var new_player: Player = Player.from_player_info(player_info)
	_add_player(new_player)
	return new_player

func _add_player(new_player: Player) -> void:
	_player_spawner.add_child(new_player, true)
	_players[new_player.player_id] = new_player
	player_connected.emit(new_player.player_id, new_player)
	print_debug("Added player: %s" % new_player.to_player_info())

func _remove_player(player: Player) -> void:
	assert(player)
	_players.erase(player.player_id)
	_player_spawner.remove_child(player)
	player.queue_free()
	print_debug("Removed player: %s!" % player.to_player_info())

func _remove_all_players(lost_connection: bool = false) -> void:
	for player: Player in _player_spawner.get_children():
		if not player:
			printerr("Lost connection to host!")
			assert(lost_connection)
			continue
		_remove_player(player)

## When a peer connects, send them the host info.
## This allows transfer of all desired data for each player, not only the unique ID.
func _on_player_connected(id: int) -> void:
	_register_player.rpc_id(id)

func _on_player_disconnected(id: int) -> void:
	var disconnected_player: Player = _player_spawner.get_node_or_null("%d" % id)
	if disconnected_player:
		_remove_player(disconnected_player)
	else:
		printerr("Host disconnected!")
	player_disconnected.emit(id, disconnected_player)
	print_debug("Player with id %d disconnected!" % id)

func _on_connected_to_server() -> void:
	print_debug("Connected to multiplayer server!")

func _on_connection_failed() -> void:
	multiplayer.multiplayer_peer = null
	print_debug("Connection failed!")

func _on_server_disconnected() -> void:
	multiplayer.multiplayer_peer = null
	_remove_all_players(true)
	server_disconnected.emit()
	print_debug("Server disconnected!")

func _on_player_name_changed(player_name: String) -> void:
	_host_player.player_name = player_name

func _get_configuration_warnings() -> PackedStringArray:
	var warnings: PackedStringArray = [ ]
	if not _player_spawner: warnings.append("Missing player spawner Node reference.")
	return warnings
