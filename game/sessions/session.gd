@icon("uid://cawf6uult17mx")
class_name Session
extends Node

static func create() -> Session:
	assert(false, "Session.create is 'abstract' and needs to be overriden!")
	return null

func start(_existing_player: Player) -> Error:
	assert(false, "Session.start is 'abstract' and needs to be overriden!")
	return Error.ERR_BUG

func stop() -> Player:
	assert(false, "Session.stop is 'abstract' and needs to be overriden!")
	return null
