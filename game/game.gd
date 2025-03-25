@icon("uid://bes0anop2dh5u")
extends Node

signal game_paused
signal game_unpaused

signal save_requested(save_file_path: StringName)
signal load_requested(save_file_path: StringName)

signal session_changed(new_session: Session)

signal player_name_changed(player_name: String)
signal game_hosted(ip_address: StringName, port: int)
signal game_joined(ip_address: StringName, port: int)
signal stopped_hosting_game
signal left_game

@warning_ignore("unused_signal")
signal random_ghost_requested

const HOST_ID: int = 1
const SAVE_FILE_PATH: StringName = "res://test.save" # "user://savegame.save"
const CONFIG_FILE_PATH: StringName = "res://config.cfg" # "user://config.cfg"

const _PLAYER_SECTION: StringName = "player"

@export var player_name: String:
	get:
		if session is MultiplayerSession:
			var multiplayer_session: MultiplayerSession = session
			if multiplayer_session.host_player:
				return multiplayer_session.host_player.player_name
		return player_name
	set(new_player_name):
		player_name = new_player_name
		if session is MultiplayerSession:
			var multiplayer_session: MultiplayerSession = session
			multiplayer_session.host_player.player_name = player_name
		player_name_changed.emit(player_name)

var session: Session:
	set(new_session):
		session = new_session
		session_changed.emit(session)

func _ready() -> void:
	_load_config()
	session_changed.connect(_on_session_changed)
	_start_singleplayer_session()

func request_pause() -> void:
	if not session is MultiplayerSession and not get_tree().paused: _pause_game()

func request_unpause() -> void:
	if get_tree().paused: _unpause_game()

func request_save(save_file_path: StringName = SAVE_FILE_PATH) -> void:
	save_requested.emit(save_file_path)

func request_load(save_file_path: StringName = SAVE_FILE_PATH) -> void:
	load_requested.emit(save_file_path)

func quit_game(save_file_path: StringName = SAVE_FILE_PATH) -> void:
	if not save_file_path.is_empty(): request_save(save_file_path)
	_update_config_file()
	get_tree().quit()

func host_game() -> void:
	var host_from_singleplayer: Player = _end_session()
	var multiplayer_session: MultiplayerSession = _initialize_multiplayer_session()
	multiplayer_session.start(host_from_singleplayer)
	game_hosted.emit(MultiplayerSession.DEFAULT_SERVER_IP, MultiplayerSession.PORT)

func join_game(ip_address: String) -> void:
	assert(ip_address.is_valid_ip_address())
	_end_session()
	var multiplayer_session: MultiplayerSession = _initialize_multiplayer_session()
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

func _start_singleplayer_session(existing_player: Player = null, save_file_path: StringName = SAVE_FILE_PATH) -> SingleplayerSession:
	assert(not session)
	var new_singleplayer_session: SingleplayerSession = SingleplayerSession.create()
	add_child(new_singleplayer_session)
	new_singleplayer_session.start(existing_player)
	session = new_singleplayer_session
	request_load(save_file_path)
	return new_singleplayer_session

func _initialize_multiplayer_session() -> MultiplayerSession:
	assert(not session)
	var new_multiplayer_session: MultiplayerSession = MultiplayerSession.create()
	session = new_multiplayer_session
	add_child(new_multiplayer_session)
	new_multiplayer_session.stopped.connect(_start_singleplayer_session)
	new_multiplayer_session.server_disconnected.connect(_on_server_disconnected)
	return new_multiplayer_session

func _end_session() -> Player:
	assert(session)
	var old_session: Session = session
	session = null
	var existing_player: Player = old_session.stop()
	remove_child(old_session)
	old_session.queue_free()
	return existing_player

func _update_config_file() -> Error:
	var config: ConfigFile = ConfigFile.new()
	config.set_value(_PLAYER_SECTION, "player_name", player_name)
	# Save it to a file (overwrite if already exists).
	config.save(CONFIG_FILE_PATH)
	print_debug("Saved config!")
	return Error.OK

func _load_config() -> Error:
	var config: ConfigFile = ConfigFile.new()
	# Load data from a file.
	var error: Error = config.load(CONFIG_FILE_PATH)
	# If the file didn't load, ignore it.
	if error != OK:
		printerr("Could not load config file due to Error %s" % error)
		return error
	
	player_name = config.get_value(_PLAYER_SECTION, "player_name")
	print_debug("Loaded config!")
	return Error.OK

func _on_session_changed(new_session: Session) -> void:
	assert(new_session == session)
	if new_session is MultiplayerSession: request_unpause()

func _on_server_disconnected() -> void:
	left_game.emit()
