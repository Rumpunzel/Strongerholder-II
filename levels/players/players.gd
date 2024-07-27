extends MultiplayerSpawner

@export var _player_scene: PackedScene = null

func _enter_tree() -> void:
	spawn_function = _spawn_player

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	# We only need to add players on the server.
	if not multiplayer.is_server(): return
	multiplayer.peer_connected.connect(_add_player)
	multiplayer.peer_disconnected.connect(_remove_player)
	
	# Spawn the local player unless this is a dedicated server export.
	if not OS.has_feature("dedicated_server"):
		_add_player(Multiplayer.HOST_PLAYER_ID)
	
	# Spawn already connected players.
	for player_id: int in multiplayer.get_peers():
		_add_player(player_id)

func _exit_tree() -> void:
	if not multiplayer.is_server(): return
	multiplayer.peer_connected.disconnect(_add_player)
	multiplayer.peer_disconnected.disconnect(_remove_player)

func _input(event : InputEvent) -> void:
	if not multiplayer.is_server(): return
	if event.is_action_pressed("ui_down"):
		_add_player(randi())

func _add_player(player_id: int) -> void:
	if not _player_scene:
		printerr("No player scene specified!")
		return
	spawn(player_id)

func _spawn_player(player_id: int) -> Player:
	var player: Player = _player_scene.instantiate()
	player.player_id = player_id
	print_debug("Added player <%d>" % player_id)
	return player

func _remove_player(player_id: int) -> void:
	if not has_node(str(player_id)):
		printerr("No player node found for id <%d> to remove!" % player_id)
		return
	var player: Player = get_node(str(player_id))
	remove_child(player)
	player.queue_free()
	print_debug("Removed player <%d>" % player_id)
