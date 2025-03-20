extends Node

signal game_continued
signal game_paused

signal game_hosted(ip_address: String, port: int)
signal game_joined(ip_address: String, port: int)
signal stopped_hosting_game
signal left_game

@onready var singleplayer_node := _initialize_singleplayer()
@onready var multiplayer_node := _initialize_multiplayer()

func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
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

func host_game() -> void:
	singleplayer_node.stop()
	multiplayer_node.host_game()
	game_hosted.emit(Multiplayer.DEFAULT_SERVER_IP, Multiplayer.PORT)
	print_debug("Started hosting multiplayer game!")

func join_game(ip_address: String) -> void:
	assert(ip_address.is_valid_ip_address())
	singleplayer_node.stop()
	multiplayer_node.join_game(ip_address)
	game_joined.emit(ip_address, Multiplayer.PORT)
	print_debug("Joined multiplayer game @ %s:%d!" % [ ip_address, Multiplayer.PORT ])

func stop_hosting_game() -> void:
	multiplayer_node.stop_hosting_game()
	stopped_hosting_game.emit()
	singleplayer_node.start()
	print_debug("Stopped hosting multiplayer game!")

func leave_game() -> void:
	multiplayer_node.leave_game()
	left_game.emit()
	singleplayer_node.start()
	print_debug("Left multiplayer game!")

func _initialize_singleplayer() -> Singleplayer:
	var new_singleplayer: Singleplayer = preload("res://singleplayer/singleplayer.tscn").instantiate()
	add_child(new_singleplayer)
	return new_singleplayer

func _initialize_multiplayer() -> Multiplayer:
	var new_multiplayer: Multiplayer = preload("res://multiplayer/multiplayer.tscn").instantiate()
	add_child(new_multiplayer)
	return new_multiplayer
