class_name Singleplayer
extends Node

signal started(player: Player)
signal stopped

@export var player_scene: PackedScene

var player: Player

func start() -> Player:
	assert(player == null)
	player = player_scene.instantiate()
	add_child(player)
	started.emit(player)
	return player

func stop() -> void:
	if not player: return
	remove_child(player)
	player.queue_free()
	player = null
	stopped.emit()
