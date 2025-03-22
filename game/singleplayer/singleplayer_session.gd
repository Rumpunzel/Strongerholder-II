class_name SingleplayerSession
extends Session

const SESSION_SCENE: PackedScene = preload("uid://cleyndjgmibpv")

var player: Player

static func create() -> SingleplayerSession:
	return SESSION_SCENE.instantiate()

func start(host_as_singleplayer: Player) -> Error:
	assert(player == null)
	if host_as_singleplayer:
		player = host_as_singleplayer
	else:
		player = Player.PLAYER_SCENE.instantiate()
	add_child(player)
	started.emit(player)
	print_debug("Started singleplayer session!")
	return Error.OK

func stop() -> Player:
	assert(player)
	remove_child(player)
	stopped.emit(player)
	print_debug("Stopped singleplayer session!")
	return player
