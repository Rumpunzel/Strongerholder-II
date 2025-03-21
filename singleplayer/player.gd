class_name Player
extends Node

@export var character_controller: CharacterController:
	set(new_character_controller):
		character_controller = new_character_controller
		set_process(character_controller != null)

var _synchronized_player_scene: PackedScene = load("uid://cuclrr5bep4gn")

@onready var _camera: TopDownCamera = %TopDownCamera

func _ready() -> void:
	if not character_controller:
		_camera.frame_point(Vector3.ZERO)
		set_process(false)

func _process(_delta: float) -> void:
	assert(character_controller)
	var input_direction := Input.get_vector("move_left", "move_right", "move_up", "move_down")
	character_controller.direction_input = _camera.get_adjusted_movement(input_direction)
	_camera.frame_node(character_controller)

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_released("pause_game") and not get_tree().paused:
		Game.pause_game()
		get_viewport().set_input_as_handled()
	elif event.is_action_released("unpause_game") and get_tree().paused:
		Game.continue_game()
		get_viewport().set_input_as_handled()

func to_synchronized_player() -> SynchronizedPlayer:
	var new_player: SynchronizedPlayer = _synchronized_player_scene.instantiate()
	new_player.player_id = Multiplayer.HOST_ID
	new_player.player_name = Game.multiplayer_node.player_name
	new_player.character_controller = character_controller
	return new_player
