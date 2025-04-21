@tool
@icon("uid://bes0anop2dh5u")
class_name Game
extends Node

signal game_paused
signal game_unpaused

@export_group("Configuration")
@export var _default_level: PackedScene
@export var _level_spawner: LevelSpawner
@export var _player_ghost_spawner: PlayerGhostSpawner
@export var _agent_spawner: AgentSpawner

var _pause_requested: bool = false

func _process(_delta: float) -> void:
	if Engine.is_editor_hint(): return
	if _pause_requested and not Multiplayer.is_online() and not get_tree().paused: _pause_game()

func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventKey:
		var key_event: InputEventKey = event
		if key_event.is_released() and key_event.keycode == KEY_F1: start_new_game()

func start_new_game() -> void:
	assert(multiplayer.is_server())
	pause_game()
	multiplayer.server_disconnected.connect(_on_disconnected_from_multiplayer)
	Multiplayer.joining_multiplayer.connect(_on_joining_multiplayer)
	Multiplayer.connected_to_multiplayer.connect(_on_connected_to_multiplayer)
	
	_level_spawner.spawn(_default_level.resource_path)
	_agent_spawner.spawn_all_from_spawn_spoints()
	_player_ghost_spawner.start_synching_players()

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
	multiplayer.server_disconnected.disconnect(_on_disconnected_from_multiplayer)
	Multiplayer.joining_multiplayer.disconnect(_on_joining_multiplayer)
	Multiplayer.connected_to_multiplayer.disconnect(_on_connected_to_multiplayer)
	
	_level_spawner.remove_all_spawned_nodes()
	_agent_spawner.remove_all_spawned_nodes()
	_player_ghost_spawner.stop_synching_players()

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

func _on_joining_multiplayer() -> void:
	stop_game()

func _on_connected_to_multiplayer() -> void:
	_unpause_game()

func _on_disconnected_from_multiplayer() -> void:
	stop_game()
	continue_game()

func _get_configuration_warnings() -> PackedStringArray:
	var warnings: PackedStringArray = []
	if not _default_level: warnings.append("Missing default level scene.")
	if not _level_spawner: warnings.append("Missing LevelSpawner reference.")
	if not _player_ghost_spawner: warnings.append("Missing PlayerGhostSpawner reference.")
	if not _agent_spawner: warnings.append("Missing AgentSpawner reference.")
	return warnings
