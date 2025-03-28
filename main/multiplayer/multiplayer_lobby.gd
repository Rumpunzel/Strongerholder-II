@icon("uid://djyg1pu0yqd4c")
class_name MultiplayerLobby
extends Node

enum RemovalReason {
	PLAYER_DISCONNECTED,
	SERVER_DISCONNECTED,
}

signal host_player_info_changed(host_player_info: Dictionary[StringName, Variant])
signal player_disconnected(player: Player)

var local_player: Player

var _guest_players: Dictionary[int, Player] = {}

func _ready() -> void:
	multiplayer.peer_disconnected.connect(_on_player_disconnected)
	multiplayer.server_disconnected.connect(_on_server_disconnected)

func add_player(player: Player) -> void:
	assert(not multiplayer.multiplayer_peer or multiplayer.is_server())
	print("players new player_id: %d" % player.player_id)
	print("players new player_name: %s" % player.player_name)
	print("players new authority: %d" % player.get_multiplayer_authority())
	player.set_multiplayer_authority(player.player_id)
	player.player_info_changed.connect(_on_player_info_changed)
	add_child(player, true)
	print_debug("Added player: %s" % player.get_player_info())

func create_local_player(player_id: int, player_name: String) -> void:
	assert(not local_player)
	var player_info: Dictionary[StringName, Variant] = {
		Player.ID: player_id,
		Player.NAME: player_name,
	}
	Player.validate_player_info(player_info)
	local_player = Player.from_player_info(player_info)
	add_player(local_player)

func change_name_for_local_player(player_name: String) -> void:
	local_player.player_name = player_name
	host_player_info_changed.emit(local_player.get_player_info())
	print_debug("Changed name of local player to: %s" % player_name)

func _remove_all_players(removal_reason: RemovalReason) -> void:
	for player: Player in get_children():
		if not player:
			assert(removal_reason == RemovalReason.SERVER_DISCONNECTED)
			printerr("Lost connection to host!")
			continue
		_remove_player(player)

func _remove_player(player: Player) -> void:
	if player == local_player: return
	assert(player)
	player.player_info_changed.disconnect(_on_player_info_changed)
	_guest_players.erase(player.player_id)
	player.queue_free()
	print_debug("Removed player: %s!" % player.get_player_info())

func _on_player_info_changed(player_info: Dictionary[StringName, Variant]) -> void:
	Player.validate_player_info(player_info)
	var player_id: int = player_info[Player.ID]
	var for_player: Player = _guest_players.get(player_id)
	if not for_player: return
	var player_name: String = player_info[Player.NAME]
	for_player.player_name = player_name
	print_debug("Changed name of player with id %d to: %s" % [player_id, player_name])

func _on_disconnected_from_multiplayer() -> void:
	_remove_all_players(RemovalReason.PLAYER_DISCONNECTED)

func _on_player_joined(player: Player) -> void:
	add_player(player)
	_guest_players[player.player_id] = player

func _on_game_joined(host_player_info: Dictionary) -> void:
	print("host_player_info: %s" % host_player_info)

func _on_player_disconnected(peer_id: int) -> void:
	var disconnected_player: Player = _guest_players.get(peer_id)
	if not disconnected_player:
		printerr("Host disconnected!")
		return
	_remove_player(disconnected_player)
	player_disconnected.emit(disconnected_player)
	print_debug("Player with player_id %d disconnected!" % peer_id)

func _on_server_disconnected() -> void:
	_remove_all_players(RemovalReason.SERVER_DISCONNECTED)

func _on_child_entered_tree(node: Node) -> void:
	assert(node is Player)
	var player: Player = node
	# Only need to do this on the client
	if not multiplayer.multiplayer_peer or multiplayer.is_server(): return
	var peer_id_from_name: int = int(player.name)
	var peer_id: int = multiplayer.get_unique_id()
	print("peer_id_from_name: %d" % peer_id_from_name)
	print("peer_id: %d" % peer_id)
	if peer_id_from_name == peer_id:
		local_player = player
		local_player.set_multiplayer_authority(peer_id)
		local_player.player_id = peer_id
	else:
		player.set_multiplayer_authority(peer_id_from_name)
		player.player_id = peer_id_from_name
