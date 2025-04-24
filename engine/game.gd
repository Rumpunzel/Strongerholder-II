@tool
@icon("uid://bes0anop2dh5u")
class_name Game
extends Node

enum GameStatus {
	NONE,
	RUNNING,
}

@export_group("Configuration")
@export var _default_level: PackedScene
@export var _level_spawner: LevelSpawner
@export var _player_ghost_spawner: PlayerGhostSpawner
@export var _agent_spawner: AgentSpawner

var _game_status: GameStatus = GameStatus.NONE

func _enter_tree() -> void:
	if Engine.is_editor_hint(): return
	Multiplayer.singleplayer_started.connect(_on_singleplayer_started)
	Multiplayer.joining_multiplayer.connect(_on_joining_multiplayer)
	Multiplayer.left_game.connect(_on_left_game)

func start_new_game() -> void:
	assert(multiplayer.is_server())
	assert(_game_status == GameStatus.NONE)
	_level_spawner.spawn(_default_level.resource_path)
	_agent_spawner.spawn_all_from_spawn_spoints()
	if Engine.is_editor_hint(): return
	_player_ghost_spawner.start_synching_players()
	_game_status = GameStatus.RUNNING

func load_game() -> Error:
	assert(multiplayer.is_server())
	assert(_game_status == GameStatus.NONE)
	var error: Error = Serializer.load_world_state()
	if error == Error.OK: _game_status = GameStatus.RUNNING
	return error

func continue_game() -> void:
	assert(multiplayer.is_server())
	if _game_status == GameStatus.RUNNING: return
	var error: Error = load_game()
	if error == Error.ERR_FILE_NOT_FOUND:
		start_new_game()

func stop_game() -> void:
	assert(multiplayer.is_server())
	print_debug("Stopping game...")
	_player_ghost_spawner.stop_synching_players()
	_agent_spawner.remove_all_agent()
	_level_spawner.unload_level()
	_game_status = GameStatus.NONE

func _on_singleplayer_started() -> void:
	continue_game()
	Client.pause_game()

func _on_joining_multiplayer() -> void:
	stop_game()

func _on_left_game() -> void:
	stop_game()

func _get_configuration_warnings() -> PackedStringArray:
	var warnings: PackedStringArray = []
	if not _default_level: warnings.append("Missing default level scene.")
	if not _level_spawner: warnings.append("Missing LevelSpawner reference.")
	if not _player_ghost_spawner: warnings.append("Missing PlayerGhostSpawner reference.")
	if not _agent_spawner: warnings.append("Missing AgentSpawner reference.")
	return warnings
