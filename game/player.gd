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

@export var _camera_scene: PackedScene = preload("uid://cnh75c8plrhf1")

var input_direction: Vector2 = Vector2.ZERO
var is_disabled: bool = false
var is_local_player: bool = true:
	set(new_is_local_player):
		is_local_player = new_is_local_player
		if _camera: _camera.current = is_local_player

## This is used for serialization purposes; serves otherwise no purpose 
var _character_controller_path: NodePath:
	set(new_character_controller_path):
		_character_controller_path = new_character_controller_path
		if character_controller or _character_controller_path.is_empty(): return
		await get_tree().process_frame
		character_controller = get_node(_character_controller_path)

var _camera: TopDownCamera:
	set(new_camera):
		if _camera:
			if get_children().has(_camera) :remove_child(_camera)
			_camera.queue_free()
		_camera = new_camera
		if not _camera: return
		add_child.call_deferred(_camera, true)

func _ready() -> void:
	_camera = _camera_scene.instantiate()
	_check_disabled()
	_collect_input()

func _process(_delta: float) -> void:
	_collect_input()
	if is_disabled: return
	assert(character_controller)
	_send_input_to_character_controller()
	_camera.frame_node(character_controller)
	if not is_local_player: return
	# Other code

static func read_movement_input() -> Vector2:
	return Input.get_vector("move_left", "move_right", "move_up", "move_down")

func _collect_input() -> void:
	if not is_local_player: return
	# Only collect input if this is the local Player
	input_direction = read_movement_input()

func _send_input_to_character_controller() -> void:
	assert(character_controller)
	character_controller.direction_input = _camera.get_adjusted_movement(input_direction)

func _check_disabled() -> void:
	is_disabled = not character_controller
