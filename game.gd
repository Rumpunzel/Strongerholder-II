extends Node

signal game_started
signal game_continued
signal game_paused

func _ready() -> void :
	pause_game()

func start_game() -> void :
	game_started.emit()
	continue_game()

func continue_game() -> void :
	get_tree().paused = false
	game_continued.emit()

func pause_game() -> void :
	get_tree().paused = true
	game_paused.emit()

func quit_game() -> void :
	get_tree().quit()
