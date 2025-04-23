@tool
@icon("uid://bes0anop2dh5u")
class_name Game
extends Node

signal game_paused
signal game_unpaused

@export_group("Configuration")
@export var _default_level: PackedScene
@export var _level_spawner: LevelSpawner
@export var _agent_spawner: AgentSpawner

var _pause_requested: bool = false

func _ready() -> void:
	Multiplayer.singleplayer_started.connect(_on_singleplayer_started)
	Multiplayer.joining_multiplayer.connect(_on_joining_multiplayer)
	Multiplayer.left_game.connect(_on_left_game)
	multiplayer.server_disconnected.connect(_on_left_game)

func _process(_delta: float) -> void:
	if Engine.is_editor_hint(): return
	if Multiplayer.is_online():
		if get_tree().paused: _unpause_game()
	else:
		if _pause_requested and not get_tree().paused: _pause_game()

func _unhandled_input(event: InputEvent) -> void:
	if Engine.is_editor_hint(): return
	if event is InputEventKey:
		var key_event: InputEventKey = event
		if key_event.is_released() and key_event.keycode == KEY_F1: start_new_game()

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

func pause_game() -> void:
	_pause_requested = true

func unpause_game() -> void:
	_unpause_game()
	_pause_requested = false

func _pause_game() -> void:
	get_tree().paused = true
	game_paused.emit()
	print_debug("Game paused...")

func _unpause_game() -> void:
	get_tree().paused = false
	game_unpaused.emit()
	print_debug("Game unpaused!")

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
