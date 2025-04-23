@tool
@icon("uid://bes0anop2dh5u")
class_name Game
extends Node

@export_group("Configuration")
@export var _default_level: PackedScene
@export var _level_spawner: LevelSpawner
@export var _agent_spawner: AgentSpawner

func _ready() -> void:
	Multiplayer.singleplayer_started.connect(_on_singleplayer_started)
	Multiplayer.joining_multiplayer.connect(_on_joining_multiplayer)
	Multiplayer.left_game.connect(_on_left_game)
	multiplayer.server_disconnected.connect(_on_left_game)

func start_new_game() -> void:
	assert(multiplayer.is_server())
	_level_spawner.spawn(_default_level.resource_path)
	_agent_spawner.spawn_all_from_spawn_spoints()

func load_game() -> Error:
	assert(multiplayer.is_server())
	var error: Error = Serializer.load_world_state()
	return error

func continue_game() -> void:
	assert(multiplayer.is_server())
	var error: Error = load_game()
	if error == Error.ERR_FILE_NOT_FOUND:
		start_new_game()

func stop_game() -> void:
	assert(multiplayer.is_server())
	print_debug("Stopping game...")
	_level_spawner.unload_level()
	_agent_spawner.remove_all_agent()

func _on_singleplayer_started() -> void:
	continue_game()

func _on_joining_multiplayer() -> void:
	stop_game()

func _on_left_game() -> void:
	stop_game()

func _get_configuration_warnings() -> PackedStringArray:
	var warnings: PackedStringArray = []
	if not _default_level: warnings.append("Missing default level scene.")
	if not _level_spawner: warnings.append("Missing LevelSpawner reference.")
	if not _agent_spawner: warnings.append("Missing AgentSpawner reference.")
	return warnings
