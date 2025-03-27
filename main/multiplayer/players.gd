@icon("uid://djyg1pu0yqd4c")
class_name Players
extends Node

enum RemovalReason {
	disconnected_from_multiplayer,
	SERVER_DISCONNECTED,
}

signal player_disconnected(player: Player)

var _guest_players: Dictionary[int, Player] = { }

@onready var _local_player: Player = _create_local_player()

static func get_local_player_info(id: int = PlayerLobby.HOST_ID) -> Dictionary:
	return {"id": id, "name": "Game.player_name"}

func _ready() -> void:
	multiplayer.peer_disconnected.connect(_on_player_disconnected)
	multiplayer.server_disconnected.connect(_on_server_disconnected)

func add_player(player: Player) -> void:
	assert(not multiplayer.multiplayer_peer or multiplayer.is_server())
	#print("players new player_id: %d" % player.player_id)
	#print("players new player_name: %s" % player.player_name)
	#player.set_multiplayer_authority(player.player_id)
	#print("players new authority: %d" % player.get_multiplayer_authority())
	add_child(player, true)
	print_debug("Added player: %s" % player.to_player_info())

func _create_local_player() -> Player:
	var local_player: Player = Player.from_player_info(get_local_player_info())
	add_player(local_player)
	return local_player

func _remove_all_players(removal_reason: RemovalReason) -> void:
	for player: Player in get_children():
		if not player:
			assert(removal_reason == RemovalReason.SERVER_DISCONNECTED)
			printerr("Lost connection to host!")
			continue
		_remove_player(player)

func _remove_player(player: Player) -> void:
	if player == _local_player: return
	assert(player)
	_guest_players.erase(player.player_id)
	player.queue_free()
	print_debug("Removed player: %s!" % player.to_player_info())

func _on_disconnected_from_multiplayer() -> void:
	_remove_all_players(RemovalReason.disconnected_from_multiplayer)

func _on_player_joined(player: Player) -> void:
	add_player(player)
	_guest_players[player.player_id] = player

func _on_player_disconnected(id: int) -> void:
	var disconnected_player: Player = _guest_players.get(id)
	if not disconnected_player:
		printerr("Host disconnected!")
		return
	_remove_player(disconnected_player)
	player_disconnected.emit(disconnected_player)
	print_debug("Player with id %d disconnected!" % id)

func _on_server_disconnected() -> void:
	_remove_all_players(RemovalReason.SERVER_DISCONNECTED)

func _on_child_entered_tree(node: Node) -> void:
	if not node is Player: return
	var player: Player = node
	print("players new player_id: %d" % player.player_id)
	print("players new player_name: %s" % player.player_name)
	player.set_multiplayer_authority(player.player_id)
	print("players new authority: %d" % player.get_multiplayer_authority())
