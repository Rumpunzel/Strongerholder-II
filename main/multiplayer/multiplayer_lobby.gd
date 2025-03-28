@icon("uid://bsnfjvi6jpfrm")
class_name MultiplayerLobby
extends Node

enum RemovalReason {
	PLAYER_DISCONNECTED,
	SERVER_DISCONNECTED,
}

signal player_disconnected(player: Player)

var _guest_players: Dictionary[int, Player] = {}

@onready var _main: MainNode = Main
@onready var _local_player: Player = _create_local_player()

func _ready() -> void:
	multiplayer.peer_disconnected.connect(_on_player_disconnected)
	multiplayer.server_disconnected.connect(_on_server_disconnected)
	
	_main.local_ghost_sprite_frame_changed.connect(_on_local_ghost_sprite_frame_changed)
	_main.local_player_name_changed.connect(_on_local_player_name_changed)

func add_player(player: Player) -> void:
	assert(not multiplayer.multiplayer_peer or multiplayer.is_server())
	player.set_multiplayer_authority(player.player_id)
	player.player_info_changed.connect(_on_player_info_changed)
	add_child(player, true)
	print_debug("Added player: %s" % player.get_player_info())

func remove_local_player() -> void:
	assert(_local_player)
	_local_player.queue_free()
	_local_player = null
	print_debug("Removed local player!")

func _create_local_player() -> Player:
	assert(not _local_player)
	var local_player: Player = Player.create(Multiplayer.HOST_ID, _main.local_player_name)
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
	player.player_info_changed.disconnect(_on_player_info_changed)
	_guest_players.erase(player.player_id)
	player.queue_free()
	print_debug("Removed player: %s!" % player.get_player_info())

func _on_local_ghost_sprite_frame_changed(local_ghost_sprite_frame: int) -> void:
	if not _local_player: return
	_local_player.ghost_sprite_frame = local_ghost_sprite_frame
	print_debug("Changed ghost sprite frame of local player to: %s" % local_ghost_sprite_frame)

func _on_local_player_name_changed(local_player_name: String) -> void:
	if not _local_player: return
	_local_player.player_name = local_player_name
	print_debug("Changed name of local player to: %s" % local_player_name)

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
	if peer_id_from_name == peer_id:
		_local_player = player
		_local_player.set_multiplayer_authority(peer_id)
		_local_player.player_id = peer_id
	else:
		player.set_multiplayer_authority(peer_id_from_name)
		player.player_id = peer_id_from_name
