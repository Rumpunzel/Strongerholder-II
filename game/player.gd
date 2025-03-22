class_name Player
extends Node

const PLAYER_SCENE: PackedScene = preload("uid://ckcrpkujohkql")

@export var character_controller: CharacterController:
	set(new_character_controller):
		character_controller = new_character_controller
		_check_disabled()
		if not character_controller:
			_character_controller_path = NodePath()
			return
		_character_controller_path = character_controller.get_path()

var does_process := true:
	set(enabled):
		does_process = enabled
		_set_process(does_process and not is_disabled)
		if does_process: print_debug("Added processing for player: %s" % name)
		else: print_debug("Removed processing for player: %s" % name)

var is_disabled := false:
	set(disabled):
		is_disabled = disabled
		_set_process(does_process and not is_disabled)
		if is_disabled: print_debug("Disabled player: %s" % name)
		else: print_debug("Enabled player: %s" % name)

var input_direction := Vector2.ZERO

## This is used for serialization purposes; serves otherwise no purpose 
var _character_controller_path: NodePath:
	set(new_character_controller_path):
		_character_controller_path = new_character_controller_path
		if character_controller or _character_controller_path.is_empty(): return
		await get_tree().process_frame
		character_controller = get_node(_character_controller_path)

@onready var _camera: TopDownCamera = %TopDownCamera

func _ready() -> void:
	_check_disabled()
	_camera.frame_point(Vector3.ZERO)
	_collect_input()

func _process(_delta: float) -> void:
	assert(does_process and not is_disabled)
	assert(character_controller)
	_collect_input()
	_send_input_to_character_controller()
	_camera.frame_node(character_controller)

static func read_movement_input() -> Vector2:
	return Input.get_vector("move_left", "move_right", "move_up", "move_down")

func _collect_input() -> void:
	input_direction = read_movement_input()

func _send_input_to_character_controller() -> void:
	assert(character_controller)
	character_controller.direction_input = _camera.get_adjusted_movement(input_direction)

func _check_disabled() -> void:
	is_disabled = not character_controller

func _set_process(enabled: bool) -> void:
	set_process(enabled)
	set_process_input(enabled)
	set_process_shortcut_input(enabled)
	set_process_unhandled_input(enabled)
	set_process_unhandled_key_input(enabled)
	set_physics_process(enabled)
	if enabled: print_debug("Enabled processing for player: %s" % name)
	else: print_debug("Disabled processing for player: %s" % name)
