class_name SingleplayerSession
extends Session

var player: Player

var _player_scene: PackedScene = load("uid://ckcrpkujohkql")

func start(host_as_singleplayer: Player = null) -> Player:
	assert(player == null)
	if host_as_singleplayer:
		player = host_as_singleplayer
	else:
		player = _player_scene.instantiate()
	add_child(player)
	started.emit(player)
	print_debug("Starting singleplayer!")
	return player

func stop() -> SynchronizedPlayer:
	assert(player)
	var host_from_singleplayer := player.to_synchronized_player()
	remove_child(player)
	player.queue_free()
	player = null
	stopped.emit(host_from_singleplayer)
	print_debug("Stopping singleplayer!")
	return host_from_singleplayer
