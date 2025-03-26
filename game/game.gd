@tool
@icon("uid://bes0anop2dh5u")
extends Node

signal game_paused
signal game_unpaused

signal save_requested(save_file_path: StringName)
signal load_requested(save_file_path: StringName)

signal player_name_changed(player_name: String)

signal game_hosted(ip_address: StringName, port: int)
signal game_joined(ip_address: StringName, port: int)
signal stopped_hosting_game
signal disconnected_from_multiplayer

@warning_ignore_start("unused_signal")
signal random_ghost_requested
@warning_ignore_restore("unused_signal")

const SAVE_FILE_PATH: StringName = "res://test.save" # "user://savegame.save"
const CONFIG_FILE_PATH: StringName = "res://config.cfg" # "user://config.cfg"

const PORT: int = 7000
const DEFAULT_SERVER_IP: StringName = "127.0.0.1" # IPv4 localhost
const MAX_CONNECTIONS: int = 4
const HOST_ID: int = 1

const _PLAYER_SECTION: StringName = "player"

@export var player_name: String:
	set(new_player_name):
		player_name = new_player_name
		player_name_changed.emit(player_name)

@onready var _lobby: Lobby

var _pause_requested: bool = false

func _ready() -> void:
	_load_config()
	if Engine.is_editor_hint(): return
	_initialize_lobby()
	multiplayer.server_disconnected.connect(leave_game)
	request_load()

func _process(_delta: float) -> void:
	if Engine.is_editor_hint(): return
	if _pause_requested and not multiplayer.multiplayer_peer and not get_tree().paused: _pause_game()

func request_pause() -> void:
	_pause_requested = true

func request_unpause() -> void:
	if get_tree().paused: _unpause_game()
	_pause_requested = false

func request_save(save_file_path: StringName = SAVE_FILE_PATH) -> void:
	save_requested.emit(save_file_path)

func request_load(save_file_path: StringName = SAVE_FILE_PATH) -> void:
	load_requested.emit(save_file_path)

func quit_game(save_file_path: StringName = SAVE_FILE_PATH) -> void:
	if not save_file_path.is_empty(): request_save(save_file_path)
	_update_config_file()
	get_tree().quit()

func host_game() -> void:
	_lobby.host_game(DEFAULT_SERVER_IP, PORT)
	game_hosted.emit(DEFAULT_SERVER_IP, PORT)
	_unpause_game()

func join_game(ip_address: String) -> void:
	assert(ip_address.is_valid_ip_address())
	_unspawn_everything()
	_lobby.join_game(ip_address, PORT)
	game_joined.emit(ip_address, PORT)
	_unpause_game()

func stop_hosting_game() -> void:
	_lobby.leave_multiplayer()
	stopped_hosting_game.emit()

func leave_game() -> void:
	_lobby.leave_multiplayer()
	disconnected_from_multiplayer.emit()
	request_load()

func _pause_game() -> void:
	get_tree().paused = true
	game_paused.emit()
	print_debug("Game paused...")

func _unpause_game() -> void:
	get_tree().paused = false
	game_unpaused.emit()
	print_debug("Game unpaused!")

func _unspawn_everything() -> void:
	get_tree().call_group("Spawners", "remove_all_spawned_nodes")

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

func _initialize_lobby() -> void:
	var lobby_scene: PackedScene = preload("uid://citi18cutmbiw")
	_lobby = lobby_scene.instantiate()
	add_child(_lobby)
