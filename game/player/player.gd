class_name Player
extends Node

@export var character_controller: CharacterController:
	set(new_character_controller):
		character_controller = new_character_controller
		is_disabled = character_controller == null
		if not character_controller:
			_character_controller_path = NodePath()
			return
		_character_controller_path = character_controller.get_path()

var input_direction := Vector2.ZERO
var does_process := true:
	set(enabled):
		does_process = enabled
		_set_process(does_process and not is_disabled)
var is_disabled := false:
	set(disabled):
		is_disabled = disabled
		_set_process(does_process and not is_disabled)

# This is used for serialization purposes; serves otherwise no purpose 
var _character_controller_path: NodePath:
	set(new_character_controller_path):
		_character_controller_path = new_character_controller_path
		if character_controller or _character_controller_path.is_empty(): return
		await get_tree().process_frame
		character_controller = get_node(_character_controller_path)

var _synchronized_player_scene: PackedScene = load("uid://cuclrr5bep4gn")

@onready var _camera: TopDownCamera = %TopDownCamera

func _ready() -> void:
	_collect_input()
	if not character_controller:
		_camera.frame_point(Vector3.ZERO)
		is_disabled = true

func _process(_delta: float) -> void:
	assert(does_process and not is_disabled)
	assert(character_controller)
	_collect_input()
	_send_input_to_character_controller()
	print("framing character: %s" % character_controller.get_path())
	_camera.frame_node(character_controller)

static func read_movement_input() -> Vector2:
	return Input.get_vector("move_left", "move_right", "move_up", "move_down")

func to_synchronized_player() -> SynchronizedPlayer:
	var new_player: SynchronizedPlayer = _synchronized_player_scene.instantiate()
	new_player.player_id = Multiplayer.HOST_ID
	new_player.player_name = Game.multiplayer_node.player_name
	new_player.character_controller = character_controller
	return new_player

func _collect_input() -> void:
	input_direction = read_movement_input()

func _send_input_to_character_controller() -> void:
	assert(character_controller)
	character_controller.direction_input = _camera.get_adjusted_movement(input_direction)

func _set_process(enabled: bool) -> void:
	set_process(enabled)
	set_process_input(enabled)
	set_process_shortcut_input(enabled)
	set_process_unhandled_input(enabled)
	set_process_unhandled_key_input(enabled)
	set_physics_process(enabled)
