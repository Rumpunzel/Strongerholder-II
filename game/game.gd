@tool
@icon("uid://bes0anop2dh5u")
class_name Game
extends Node

signal game_paused
signal game_unpaused

@export_group("Configuration")
@export var _player_ghost_spawner: PlayerGhostSpawner
@export var _agent_spawner: AgentSpawner

var _pause_requested: bool = false

func _ready() -> void:
	if Engine.is_editor_hint(): return
	pause_game()
	
	multiplayer.server_disconnected.connect(_on_disconnected_from_multiplayer)
	Multiplayer.connected_to_multiplayer.connect(_on_connected_to_multiplayer)
	
	Serializer.load_world_state()

func _process(_delta: float) -> void:
	if Engine.is_editor_hint(): return
	if _pause_requested and not multiplayer.multiplayer_peer and not get_tree().paused: _pause_game()

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

func _on_connected_to_multiplayer() -> void:
	_unpause_game()

func _on_disconnected_from_multiplayer() -> void:
	Serializer.load_world_state()

func _get_configuration_warnings() -> PackedStringArray:
	var warnings: PackedStringArray = []
	if not _player_ghost_spawner: warnings.append("Missing PlayerGhostSpawner reference.")
	if not _agent_spawner: warnings.append("Missing AgentSpawner reference.")
	return warnings
