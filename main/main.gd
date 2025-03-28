@tool
@icon("uid://csn6gjpak3yxk")
class_name MainNode
extends Node

signal local_player_name_changed(local_player_name: String)
signal local_ghost_sprite_frame_changed(local_ghost_sprite_frame: int)

const CONFIG_FILE_PATH: StringName = "res://config.cfg" # "user://config.cfg"

var local_player_name: String:
	set(new_local_player_name):
		local_player_name = new_local_player_name
		local_player_name_changed.emit(local_player_name)
		update_value_in_config(_PLAYER_SECTION, _LOCAL_PLAYER_NAME, local_player_name)

var local_ghost_sprite_frame: int:
	set(new_local_ghost_sprite_frame):
		local_ghost_sprite_frame = new_local_ghost_sprite_frame
		local_ghost_sprite_frame_changed.emit(local_ghost_sprite_frame)
		update_value_in_config(_PLAYER_SECTION, _LOCAL_GHOST_SPRITE_FRAME, local_ghost_sprite_frame)

## Config
const _PLAYER_SECTION: StringName = "player"
const _LOCAL_PLAYER_NAME: StringName = "local_player_name"
const _LOCAL_GHOST_SPRITE_FRAME: StringName = "local_ghost_sprite_frame"

@export_group("Configuration")
@export var _multiplayer: Multiplayer
@export var _main_menu: MainMenu

var _pause_requested: bool = false

var _config: ConfigFile = _load_config_file()

@onready var _serializer: SerializerNode = Serializer

func _ready() -> void:
	if Engine.is_editor_hint(): return
	#Game.load_requested.connect(request_pause)
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

func host_game() -> void:
	_multiplayer.host_game()
	_unpause_game()

func join_game(ip_address: StringName) -> void:
	_multiplayer.join_game(ip_address)
	_unpause_game()

func disconnect_from_multiplayer() -> void:
	_multiplayer.disconnect_from_multiplayer()

func quit_game(save_file_path: StringName = SerializerNode.SAVE_FILE_PATH) -> void:
	if not save_file_path.is_empty(): _serializer.save_world_state(save_file_path)
	get_tree().quit()

func update_value_in_config(section: String, key: String, value: Variant) -> Error:
	assert(not section.is_empty())
	assert(not key.is_empty())
	assert(_config)
	_config.set_value(section, key, value)
	return _update_config_file()

func update_values_in_config(config_entries: Array[ConfigEntry]) -> Error:
	assert(not config_entries.is_empty())
	assert(_config)
	for config_entry: ConfigEntry in config_entries:
		_config.set_value(config_entry.section, config_entry.key, config_entry.value)
	return _update_config_file()

func get_value_from_config(section: String, key: String, default_value: Variant = null) -> Variant:
	return _config.get_value(section, key, default_value)

func get_values_from_config(section: String, keys: Array[String], default_value: Variant = null) -> Dictionary[String, Variant]:
	var values: Dictionary[String, Variant] = {}
	for key: String in keys:
		var value: Variant = _config.get_value(section, key, default_value)
		values[key] = value
	return values

func _pause_game() -> void:
	get_tree().paused = true
	_main_menu.open_menu()
	print_debug("Game paused...")

func _unpause_game() -> void:
	get_tree().paused = false
	print_debug("Game unpaused!")

func _update_config_file() -> Error:
	# Save it to a file (overwrite if already exists).
	var error: Error = _config.save(CONFIG_FILE_PATH)
	if error == OK: print_debug("Saved config!")
	else: printerr("Could not save config file due to Error %s" % error)
	return error

static func _load_config_file() -> ConfigFile:
	if not FileAccess.file_exists(CONFIG_FILE_PATH):
		print_debug("No config file found, creating default!")
		var default_error: Error = _create_default_config_file()
		if default_error != OK: return null
	
	var config: ConfigFile = ConfigFile.new()
	# Load data from a file.
	var error: Error = config.load(CONFIG_FILE_PATH)
	# If the file didn't load, ignore it.
	if error != OK:
		printerr("Could not load config file due to Error %s" % error)
		return null
	print_debug("Loaded config!")
	return config

static func _create_default_config_file() -> Error:
	var default_config: ConfigFile = ConfigFile.new()
	var error: Error = default_config.save(CONFIG_FILE_PATH)
	if error == OK: print_debug("Saved default config!")
	else: printerr("Could not save default config file due to Error %s" % error)
	return error

func _on_disconnected_from_multiplayer() -> void:
	_serializer.load_world_state()

func _get_configuration_warnings() -> PackedStringArray:
	var warnings: PackedStringArray = [ ]
	if not _main_menu: warnings.append("Missing MainMenu reference.")
	return warnings

class ConfigEntry:
	var section: String
	var key: String
	var value: Variant
	func _init(new_section: String, new_key: String, new_value: Variant) -> void:
		section = new_section
		key = new_key
		value = new_value
