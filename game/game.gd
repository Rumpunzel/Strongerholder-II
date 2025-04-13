@tool
@icon("uid://bes0anop2dh5u")
class_name Game
extends Node

signal game_paused
signal game_unpaused

const GAME_SCENE: PackedScene = preload("uid://bvt1s3i2xw5s6")

@export_group("Configuration")
@export var _agent_spawner: AgentSpawner

var _pause_requested: bool = false

func _ready() -> void:
	if Engine.is_editor_hint(): return
	pause_game()
	
	multiplayer.server_disconnected.connect(_on_disconnected_from_multiplayer)
	Multiplayer.connected_to_multiplayer.connect(_on_connected_to_multiplayer)
	
	if Multiplayer.is_client(): return
	var error: Error = Serializer.load_world_state()
	if not error == Error.OK:
		_agent_spawner.spawn_all_from_spawn_spoints()

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
	get_tree().reload_current_scene()

func _get_configuration_warnings() -> PackedStringArray:
	var warnings: PackedStringArray = []
	if not _agent_spawner: warnings.append("Missing AgentSpawner reference.")
	return warnings
