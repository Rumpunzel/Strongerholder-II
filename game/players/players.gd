@icon("uid://djyg1pu0yqd4c")
class_name Players
extends Node

enum RemovalReason {
	MULTIPLAYER_STOPPED,
	SERVER_DISCONNECTED,
}

@onready var _local_player: Player = _create_local_player()

static func get_local_player_info(id: int = Game.HOST_ID) -> Dictionary:
	return { "id": id, "name": Game.player_name }

func _ready() -> void:
	multiplayer.peer_disconnected.connect(_on_player_disconnected)
	multiplayer.server_disconnected.connect(_on_server_disconnected)

func add_player(player: Player) -> void:
	assert(not multiplayer.multiplayer_peer or multiplayer.is_server())
	add_child(player, true)
	print_debug("Added player: %s" % player.to_player_info())

func _create_local_player() -> Player:
	var local_player: Player = Player.from_player_info(get_local_player_info())
	add_player(local_player)
	return local_player

func _on_multiplayer_stopped() -> void:
	_remove_all_players(RemovalReason.MULTIPLAYER_STOPPED)

func _on_player_joined(player: Player) -> void:
	add_player(player)

func _on_player_disconnected(id: int) -> void:
	var disconnected_player: Player = get_node_or_null("%d" % id)
	if not disconnected_player:
		printerr("Host disconnected!")
		return
	_remove_player(disconnected_player)
	print_debug("Player with id %d disconnected!" % id)

func _on_server_disconnected() -> void:
	_remove_all_players(RemovalReason.SERVER_DISCONNECTED)

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
	#remove_child(player)
	player.queue_free()
	print_debug("Removed player: %s!" % player.to_player_info())
