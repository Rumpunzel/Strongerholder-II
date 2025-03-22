extends Node

signal session_changed(new_session: Session)

signal game_paused
signal game_unpaused

signal game_hosted(ip_address: String, port: int)
signal game_joined(ip_address: String, port: int)
signal stopped_hosting_game
signal left_game

const HOST_ID := 1

var session: Session:
	set(new_session):
		session = new_session
		session_changed.emit(session)

@onready var _serialization := _initialize_serialization()

func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	request_pause()
	session_changed.connect(_on_session_changed)
	_start_singleplayer_session.call_deferred()

func request_pause() -> void:
	if not session is MultiplayerSession and not get_tree().paused: _pause_game()

func request_unpause() -> void:
	if get_tree().paused: _unpause_game()

func quit_game() -> void:
	get_tree().quit()

func host_game() -> void:
	var host_from_singleplayer := _end_session()
	var multiplayer_session := _initialize_multiplayer_session()
	multiplayer_session.start(host_from_singleplayer)
	game_hosted.emit(MultiplayerSession.DEFAULT_SERVER_IP, MultiplayerSession.PORT)

func join_game(ip_address: String) -> void:
	assert(ip_address.is_valid_ip_address())
	_end_session()
	var multiplayer_session := _initialize_multiplayer_session()
	multiplayer_session.join_game(ip_address)
	game_joined.emit(ip_address, MultiplayerSession.PORT)

func stop_hosting_game() -> void:
	assert(session is MultiplayerSession)
	_end_session()
	stopped_hosting_game.emit()

func leave_game() -> void:
	assert(session is MultiplayerSession)
	_end_session()
	left_game.emit()

func _pause_game() -> void:
	get_tree().paused = true
	game_paused.emit()
	print_debug("Game paused...")

func _unpause_game() -> void:
	get_tree().paused = false
	game_unpaused.emit()
	print_debug("Game unpaused!")

func _start_singleplayer_session(existing_player: Player = null) -> SingleplayerSession:
	assert(not session)
	assert(not existing_player is SynchronizedPlayer)
	var new_singleplayer_session := SingleplayerSession.create()
	session = new_singleplayer_session
	add_child(new_singleplayer_session)
	new_singleplayer_session.start(existing_player)
	return new_singleplayer_session

func _initialize_multiplayer_session() -> MultiplayerSession:
	assert(not session)
	var new_multiplayer_session := MultiplayerSession.create()
	session = new_multiplayer_session
	add_child(new_multiplayer_session)
	new_multiplayer_session.stopped.connect(_start_singleplayer_session)
	new_multiplayer_session.server_disconnected.connect(_on_server_disconnected)
	return new_multiplayer_session

func _end_session() -> Player:
	assert(session)
	var old_session := session
	session = null
	var existing_player := old_session.stop()
	remove_child(old_session)
	old_session.queue_free()
	return existing_player

func _initialize_serialization() -> Serialization:
	assert(not _serialization)
	_serialization = Serialization.new()
	add_child(_serialization)
	return _serialization

func _on_session_changed(new_session: Session) -> void:
	assert(new_session == session)
	if new_session is MultiplayerSession: request_unpause()

func _on_server_disconnected() -> void:
	left_game.emit()
