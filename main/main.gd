@tool
@icon("uid://csn6gjpak3yxk")
extends Node

@warning_ignore_start("unused_signal")
signal random_ghost_requested
@warning_ignore_restore("unused_signal")

const CONFIG_FILE_PATH: StringName = "res://config.cfg" # "user://config.cfg"

@export_group("Configuration")
@export var _main_menu: MainMenu

var _pause_requested: bool = false

func _ready() -> void:
	_load_config()
	if Engine.is_editor_hint(): return
	#Gameplay.load_requested.connect(request_pause)
	pause_game()
	multiplayer.server_disconnected.connect(_on_disconnected_from_multiplayer)

func _process(_delta: float) -> void:
	if Engine.is_editor_hint(): return
	if _pause_requested and not multiplayer.multiplayer_peer and not get_tree().paused: _pause_game()

func pause_game() -> void:
	_pause_requested = true

func unpause_game() -> void:
	_unpause_game()
	_pause_requested = false

func quit_game(save_file_path: StringName = Serializer.SAVE_FILE_PATH) -> void:
	if not save_file_path.is_empty(): Gameplay.request_save(save_file_path)
	_update_config_file()
	get_tree().quit()

func _on_disconnected_from_multiplayer() -> void:
	Gameplay.request_load()

func _pause_game() -> void:
	get_tree().paused = true
	_main_menu.open_menu()
	print_debug("Game paused...")

func _unpause_game() -> void:
	get_tree().paused = false
	print_debug("Game unpaused!")

func _update_config_file() -> Error:
	var config: ConfigFile = ConfigFile.new()
	# Save it to a file (overwrite if already exists).
	var error: Error = config.save(CONFIG_FILE_PATH)
	if error == OK: print_debug("Saved config!")
	else: printerr("Could not save config file due to Error %s" % error)
	return error

func _load_config() -> Error:
	if not FileAccess.file_exists(CONFIG_FILE_PATH):
		print_debug("No config file found, creating default!")
		var default_config: ConfigFile = ConfigFile.new()
		var default_error: Error = default_config.save(CONFIG_FILE_PATH)
		if default_error == OK: print_debug("Saved default config!")
		else:
			printerr("Could not save default config file due to Error %s" % default_error)
			return default_error
	var config: ConfigFile = ConfigFile.new()
	# Load data from a file.
	var error: Error = config.load(CONFIG_FILE_PATH)
	# If the file didn't load, ignore it.
	if error == OK:
		print_debug("Loaded config!")
	else: printerr("Could not load config file due to Error %s" % error)
	return error

func _on_game_hosted(_ip_address: StringName, _port: int) -> void:
	_unpause_game()

func _on_game_joined(_host_player_info: Dictionary) -> void:
	_unpause_game()

func _get_configuration_warnings() -> PackedStringArray:
	var warnings: PackedStringArray = [ ]
	if not _main_menu: warnings.append("Missing MainMenu reference.")
	return warnings
