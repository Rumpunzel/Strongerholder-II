@tool
@icon("uid://c73t2rg8wrdt3")
class_name Player
extends Node

const PLAYER_SCENE: PackedScene = preload("uid://ckcrpkujohkql")

@export var character_controller: CharacterController:
	set(new_character_controller):
		character_controller = new_character_controller
		_check_disabled()
		if not character_controller:
			character = null
			_character_controller_path = NodePath()
			return
		character = character_controller.character
		_character_controller_path = character_controller.get_path()

@export_group("Configuration")
@export var _camera: TopDownCamera
@export var _hit_box: HitBox
@export var _interaction_area: InteractionArea

var character: Character:
	set(new_character):
		character = new_character
		_hit_box.character = character
		_interaction_area.character = character

var is_disabled: bool = false:
	set(new_is_disabled):
		is_disabled = new_is_disabled
		_hit_box.visible = not is_disabled
		_interaction_area.visible = not is_disabled

var is_local_player: bool = true:
	set(new_is_local_player):
		is_local_player = new_is_local_player
		if _camera: _camera.current = is_local_player

var input_direction: Vector2 = Vector2.ZERO

## This is used for serialization purposes; serves otherwise no purpose 
var _character_controller_path: NodePath:
	set(new_character_controller_path):
		_character_controller_path = new_character_controller_path
		if character_controller or _character_controller_path.is_empty(): return
		await get_tree().process_frame
		character_controller = get_node(_character_controller_path)

func _ready() -> void:
	_check_disabled()
	if Engine.is_editor_hint(): return
	_collect_input()

func _process(_delta: float) -> void:
	if Engine.is_editor_hint(): return
	_collect_input()
	if is_disabled: return
	assert(character_controller)
	_send_input_to_character_controller()
	_camera.frame_node(character_controller)
	_hit_box.follow_node(character_controller)
	_interaction_area.follow_node(character_controller)
	if not is_local_player: return
	# Other code

static func create() -> Player:
	return PLAYER_SCENE.instantiate()

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
	if Engine.is_editor_hint(): return
	is_disabled = not character_controller

func _get_configuration_warnings() -> PackedStringArray:
	var warnings: PackedStringArray = [ ]
	if not _camera: warnings.append("Missing Camera reference.")
	if not _hit_box: warnings.append("Missing HitBox reference.")
	if not _interaction_area: warnings.append("Missing InteractionArea reference.")
	return warnings
