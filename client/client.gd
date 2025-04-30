@icon("uid://csn6gjpak3yxk")
extends Node

signal game_paused
signal game_unpaused

var _pause_requested: bool = false

func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS

func _process(_delta: float) -> void:
	if Multiplayer.is_online():
		if get_tree().paused: _unpause_game()
	else:
		if _pause_requested and not get_tree().paused: _pause_game()

func quit_game() -> void:
	get_tree().quit()

func pause_game() -> void:
	_pause_requested = true

func unpause_game() -> void:
	_unpause_game()
	_pause_requested = false

func _pause_game() -> void:
	get_tree().paused = true
	game_paused.emit()

func _unpause_game() -> void:
	get_tree().paused = false
	game_unpaused.emit()
