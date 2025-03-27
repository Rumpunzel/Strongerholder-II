@tool
@icon("uid://bes0anop2dh5u")
extends Node

@warning_ignore_start("unused_signal")
signal random_ghost_requested
@warning_ignore_restore("unused_signal")

const CONFIG_FILE_PATH: StringName = "res://config.cfg" # "user://config.cfg"

const _PLAYER_SECTION: StringName = "player"

@export var player_name: String:
	set(new_player_name):
		player_name = new_player_name
		#player_name_changed.emit(player_name)

@export_group("Configuration")
@export var _main_menu: MainMenu

var _pause_requested: bool = false

func _ready() -> void:
	_load_config()
	if Engine.is_editor_hint(): return
	#Gameplay.load_requested.connect(request_pause)
	multiplayer.server_disconnected.connect(_on_disconnected_from_multiplayer)

func _process(_delta: float) -> void:
	if Engine.is_editor_hint(): return
	if _pause_requested and not multiplayer.multiplayer_peer and not get_tree().paused: _pause_game()

func _unhandled_input(event: InputEvent) -> void:
	if Engine.is_editor_hint(): return
	if event.is_action_released("open_menu"):
		_main_menu.open_menu()
		request_pause()
		get_viewport().set_input_as_handled()
	elif event.is_action_released("close_menu"):
		if get_tree().paused: _unpause_game()
		_main_menu.close_menu()
		get_viewport().set_input_as_handled()

func request_pause() -> void:
	_pause_requested = true

func request_unpause() -> void:
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

#func _unspawn_everything() -> void:
	#get_tree().call_group("Spawners", "remove_all_spawned_nodes")

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

func _get_configuration_warnings() -> PackedStringArray:
	var warnings: PackedStringArray = [ ]
	if not _main_menu: warnings.append("Missing MainMenu reference.")
	return warnings
