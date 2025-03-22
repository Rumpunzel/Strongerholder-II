class_name Session
extends Node

signal started(player: Player)
signal stopped(existing_player: Player)

@export var player_name: String

static func create() -> Session:
	assert(false, "Session.create is 'abstract' and needs to be overriden!")
	return null

func start(_existing_player: Player) -> Error:
	assert(false, "Session.start is 'abstract' and needs to be overriden!")
	started.emit(null)
	return Error.ERR_BUG

func stop() -> Player:
	assert(false, "Session.stop is 'abstract' and needs to be overriden!")
	stopped.emit(null)
	return null
