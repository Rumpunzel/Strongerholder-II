@icon("uid://csn6gjpak3yxk")
class_name MainNode
extends Node

const CONFIG_FILE_PATH: StringName = "res://config.cfg" # "user://config.cfg"

## Config
const _LOCAL_PLAYER_SECTION: StringName = "local_player"
const _LOCAL_PLAYER_NAME: StringName = "local_player_name"
const _LOCAL_GHOST_SPRITE_FRAME: StringName = "local_ghost_sprite_frame"

var _config: ConfigFile = _load_config_file()

func _ready() -> void:
	if _config.has_section_key(_LOCAL_PLAYER_SECTION, _LOCAL_PLAYER_NAME):
		Lobby.local_player_name = get_value_from_config(_LOCAL_PLAYER_SECTION, _LOCAL_PLAYER_NAME)
	if _config.has_section_key(_LOCAL_PLAYER_SECTION, _LOCAL_GHOST_SPRITE_FRAME):
		Lobby.local_ghost_sprite_frame = get_value_from_config(_LOCAL_PLAYER_SECTION, _LOCAL_GHOST_SPRITE_FRAME)
	
	Lobby.local_player_name_changed.connect(update_value_in_config.bind(_LOCAL_PLAYER_SECTION, _LOCAL_PLAYER_NAME))
	Lobby.local_ghost_sprite_frame_changed.connect(update_value_in_config.bind(_LOCAL_PLAYER_SECTION, _LOCAL_GHOST_SPRITE_FRAME))

func quit_game() -> void:
	Serializer.save_world_state()
	get_tree().quit()

func update_value_in_config(value: Variant, section: String, key: String) -> Error:
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

class ConfigEntry:
	var value: Variant
	var section: String
	var key: String
	func _init(new_value: Variant, new_section: String, new_key: String) -> void:
		value = new_value
		section = new_section
		key = new_key
