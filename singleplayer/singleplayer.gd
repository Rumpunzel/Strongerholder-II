class_name Singleplayer
extends Node

signal started(player: Player)
signal stopped

@export var player_scene: PackedScene

@onready var _player: Player = start()

func start() -> Player:
	assert(_player == null)
	_player = player_scene.instantiate()
	add_child(_player)
	started.emit(_player)
	return _player

func stop() -> void:
	assert(_player != null)
	remove_child(_player)
	_player.queue_free()
	_player = null
	stopped.emit()
