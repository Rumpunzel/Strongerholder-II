extends Node

signal game_paused
signal game_continued

func _ready() -> void:
	# Preconfigure game.
	process_mode = Node.PROCESS_MODE_ALWAYS
	Multiplayer.player_loaded.rpc_id(Multiplayer.host_id) # Tell the server that this peer has loaded.
	pause_game()

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_released("pause_game") and not get_tree().paused:
		pause_game()
		get_viewport().set_input_as_handled()
	elif event.is_action_released("unpause_game") and get_tree().paused:
		continue_game()
		get_viewport().set_input_as_handled()

func pause_game() -> void:
	get_tree().paused = true
	game_paused.emit()

func continue_game() -> void:
	get_tree().paused = false
	game_continued.emit()

func quit_game() -> void:
	get_tree().quit()
