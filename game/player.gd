@icon("uid://c73t2rg8wrdt3")
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

var input_direction := Vector2.ZERO
var does_process := true
var is_disabled := false

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
	_collect_input()
	if is_disabled: return
	assert(character_controller)
	_send_input_to_character_controller()
	_camera.frame_node(character_controller)
	if not does_process: return
	assert(does_process and not is_disabled)
	# Other code

static func read_movement_input() -> Vector2:
	return Input.get_vector("move_left", "move_right", "move_up", "move_down")

func _collect_input() -> void:
	if not does_process: return
	# Only collect input if this Player processes
	input_direction = read_movement_input()

func _send_input_to_character_controller() -> void:
	assert(character_controller)
	character_controller.direction_input = _camera.get_adjusted_movement(input_direction)

func _check_disabled() -> void:
	is_disabled = not character_controller
