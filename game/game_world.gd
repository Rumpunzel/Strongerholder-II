@icon("uid://bq2ao4pir5jfp")
class_name GameWorld
extends Node

signal game_paused
signal game_unpaused

var _pause_requested: bool = false

func _ready() -> void:
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
