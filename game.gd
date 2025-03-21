extends Node

signal game_continued
signal game_paused

signal game_hosted(ip_address: String, port: int)
signal game_joined(ip_address: String, port: int)
signal stopped_hosting_game
signal left_game

var singleplayer_node: Singleplayer
var multiplayer_node: Multiplayer

func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	_initialize_singleplayer()
	_initialize_multiplayer()
	pause_game()
	singleplayer_node.start.call_deferred()

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
	var host_from_singleplayer := singleplayer_node.stop()
	multiplayer_node.host_game(host_from_singleplayer)
	game_hosted.emit(Multiplayer.DEFAULT_SERVER_IP, Multiplayer.PORT)
	print_debug("Started hosting multiplayer game!")

func join_game(ip_address: String) -> void:
	assert(ip_address.is_valid_ip_address())
	singleplayer_node.stop()
	multiplayer_node.join_game(ip_address)
	game_joined.emit(ip_address, Multiplayer.PORT)
	print_debug("Joined multiplayer game @ %s:%d!" % [ ip_address, Multiplayer.PORT ])

func stop_hosting_game() -> void:
	var host_as_singleplayer := multiplayer_node.stop_hosting_game()
	stopped_hosting_game.emit()
	singleplayer_node.start(host_as_singleplayer)
	print_debug("Stopped hosting multiplayer game!")

func leave_game() -> void:
	multiplayer_node.leave_game()
	left_game.emit()
	singleplayer_node.start()
	print_debug("Left multiplayer game!")

func _initialize_singleplayer() -> void:
	assert(not singleplayer_node)
	singleplayer_node = preload("uid://cleyndjgmibpv").instantiate()
	add_child(singleplayer_node)

func _initialize_multiplayer() -> void:
	assert(not multiplayer_node)
	multiplayer_node = preload("uid://citi18cutmbiw").instantiate()
	add_child(multiplayer_node)
	multiplayer_node.server_disconnected.connect(_on_server_disconnected)

func _on_server_disconnected() -> void:
	print_debug("Server disconnected!")
	leave_game()
