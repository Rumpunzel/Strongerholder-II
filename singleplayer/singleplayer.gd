class_name Singleplayer
extends Node

signal started(player: Player)
signal stopped

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
	return player

func stop() -> SynchronizedPlayer:
	assert(player)
	var host_from_singleplayer := player.to_synchronized_player()
	remove_child(player)
	player.queue_free()
	player = null
	stopped.emit()
	return host_from_singleplayer
