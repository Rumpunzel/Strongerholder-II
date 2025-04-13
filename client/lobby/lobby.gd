@tool
@icon("uid://bsnfjvi6jpfrm")
extends Spawner

enum RemovalReason {
	PLAYER_DISCONNECTED,
	SERVER_DISCONNECTED,
}

signal player_connected(player: Player)
signal player_disconnected(player: Player)

signal local_player_name_changed(local_player_name: String)
signal local_ghost_sprite_frame_changed(local_ghost_sprite_frame: int)

var local_player_name: String:
	set(new_local_player_name):
		local_player_name = new_local_player_name
		local_player_name_changed.emit(local_player_name)
		print_debug("Changed name of local player to: %s" % local_player_name)

var local_ghost_sprite_frame: int:
	set(new_local_ghost_sprite_frame):
		local_ghost_sprite_frame = new_local_ghost_sprite_frame
		local_ghost_sprite_frame_changed.emit(local_ghost_sprite_frame)
		print_debug("Changed ghost sprite frame of local player to: %s" % local_ghost_sprite_frame)

var _local_player: Player
var _guest_players: Dictionary[int, Player] = {}

func _enter_tree() -> void:
	spawn_path = get_path()
	if Engine.is_editor_hint(): return
	add_spawnable_scene(Player.PLAYER_SCENE.resource_path)
	child_entered_tree.connect(_on_child_entered_tree)

func _ready() -> void:
	if Engine.is_editor_hint(): return
	multiplayer.peer_disconnected.connect(_on_player_disconnected)
	multiplayer.server_disconnected.connect(_on_server_disconnected)
	
	Multiplayer.player_joined.connect(_on_player_joined)
	Multiplayer.game_joined.connect(_on_game_joined)
	Multiplayer.disconnected_from_multiplayer.connect(_on_disconnected_from_multiplayer)
	
	_create_local_player()

func get_connected_players() -> Array[Player]:
	var connected_players: Array[Player] = [_local_player]
	connected_players.append_array(_guest_players.values())
	return connected_players

func get_player(player_id: int) -> Player:
	if player_id == _local_player.player_id: return _local_player
	return _guest_players[player_id]

func add_player(player: Player) -> void:
	assert(Multiplayer.is_server())
	player.set_multiplayer_authority(player.player_id)
	player.player_info_changed.connect(_on_player_info_changed)
	add_child(player, true)
	player_connected.emit(player)
	print_debug("Added player: %s" % player.get_player_info())

func remove_local_player() -> void:
	assert(_local_player)
	_local_player.queue_free()
	_local_player = null
	print_debug("Removed local player!")

func _create_local_player() -> void:
	assert(not _local_player)
	_local_player = Player.create(Multiplayer.HOST_ID, local_player_name)
	add_player(_local_player)

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
	if not Multiplayer.is_client(): return
	assert(player.name.is_valid_int())
	var peer_id_from_name: int = int(player.name)
	var peer_id: int = multiplayer.get_unique_id()
	player.set_multiplayer_authority(peer_id_from_name)
	player.player_id = peer_id_from_name
	if peer_id_from_name == peer_id: _local_player = player
