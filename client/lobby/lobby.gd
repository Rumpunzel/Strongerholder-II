@tool
@icon("uid://bsnfjvi6jpfrm")
extends Spawner

enum RemovalReason {
	JOINING_GAME,
	PLAYER_DISCONNECTED,
	SERVER_DISCONNECTED,
}

signal player_connected(player: Player)
signal player_disconnected(player: Player)

signal player_info_changed(player: Player)

func _enter_tree() -> void:
	spawn_path = get_path()
	spawn_function = _spawn_player
	if Engine.is_editor_hint(): return
	add_spawnable_scene(Player.PLAYER_SCENE.resource_path)
	child_entered_tree.connect(_on_child_entered_tree)

func _ready() -> void:
	super._ready()
	if Engine.is_editor_hint(): return
	multiplayer.peer_disconnected.connect(_on_player_disconnected)
	multiplayer.server_disconnected.connect(_on_server_disconnected)
	
	Multiplayer.joining_multiplayer.connect(_on_joining_multiplayer)
	Multiplayer.player_joined.connect(_on_player_joined)
	Multiplayer.game_joined.connect(_on_game_joined)
	Multiplayer.disconnected_from_multiplayer.connect(_on_disconnected_from_multiplayer)
	
	_create_local_player()

func get_connected_players() -> Array[Player]:
	var players: Array[Player] = []
	for child: Node in get_children():
		if child is Player: players.append(child)
	return players

func get_player(player_id: int) -> Player:
	for player: Player in get_connected_players():
		if player.player_id == player_id: return player
	return null

func get_local_player() -> Player:
	var local_player_id: int = Multiplayer.HOST_ID
	if multiplayer and get_connected_players().size() > 1: local_player_id = multiplayer.get_unique_id()
	var local_player: Player = get_player(local_player_id)
	if not local_player:
		for player: Player in get_connected_players():
			if player.is_local_player(): local_player = player
	assert(local_player)
	return local_player

func _spawn_player(player: Player) -> void:
	assert(Multiplayer.is_server())
	player.set_multiplayer_authority(player.player_id)
	add_child(player, true)
	player_connected.emit(player)
	print_debug("Added player: %s" % player.get_player_info())

func _create_local_player() -> void:
	assert(get_child_count() == 0)
	_spawn_player(Player.create(Multiplayer.HOST_ID))

func _remove_all_players(removal_reason: RemovalReason) -> void:
	for player: Player in get_children():
		if not player:
			assert(removal_reason == RemovalReason.SERVER_DISCONNECTED)
			printerr("Lost connection to host!")
			continue
		if player.is_local_player():
			continue
		_remove_player(player)

func _remove_player(player: Player) -> void:
	assert(player)
	player.player_info_changed.disconnect(_on_player_info_changed)
	player.queue_free()
	print_debug("Removed player: %s!" % player.get_player_info())

func _on_player_info_changed(player_info: Dictionary[StringName, Variant]) -> void:
	Player.validate_player_info(player_info)
	var player_id: int = player_info[Player.ID]
	var for_player: Player = get_player(player_id)
	if not for_player: return
	var player_name: String = player_info[Player.NAME]
	for_player.player_name = player_name
	print_debug("Changed name of player with id %d to: %s" % [player_id, player_name])

func _on_disconnected_from_multiplayer() -> void:
	_remove_all_players(RemovalReason.PLAYER_DISCONNECTED)

func _on_joining_multiplayer() -> void:
	_remove_all_players(RemovalReason.JOINING_GAME)

func _on_player_joined(player: Player) -> void:
	_spawn_player(player)

func _on_game_joined(host_player_info: Dictionary) -> void:
	print("host_player_info: %s" % host_player_info)

func _on_player_disconnected(peer_id: int) -> void:
	var disconnected_player: Player = get_player(peer_id)
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
	player.player_info_changed.connect(player_info_changed.emit.bind(player))
	# Only need to do this on the client
	if not Multiplayer.is_client(): return
	assert(player.name.is_valid_int())
	var peer_id_from_name: int = int(player.name)
	player.player_id = peer_id_from_name
	player.set_multiplayer_authority(player.player_id)
	print("player_id: %d" % peer_id_from_name)
