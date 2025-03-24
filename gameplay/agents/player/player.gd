@tool
@icon("uid://nl71yast8tsi")
class_name Player
extends Node

const PLAYER_SCENE: PackedScene = preload("uid://ckcrpkujohkql")

@export var character_controller: CharacterController:
	set(new_character_controller):
		character_controller = new_character_controller
		_agent.character_controller = character_controller
		_check_disabled()
		if not character_controller:
			character = null
			return
		character = character_controller.character

@export_group("Configuration")
@export var _camera: TopDownCamera
@export var _agent: Agent
@export var _interaction_area: InteractionArea

var character: Character:
	set(new_character):
		character = new_character
		_interaction_area.character = character

var is_disabled: bool = false:
	set(new_is_disabled):
		is_disabled = new_is_disabled
		_interaction_area.visible = not is_disabled

var is_local_player: bool = true:
	set(new_is_local_player):
		is_local_player = new_is_local_player
		if _camera: _camera.current = is_local_player

var input_direction: Vector2 = Vector2.ZERO

## This is used for serialization purposes; serves otherwise no purpose
var _character_controller_path: NodePath:
	get: return character_controller.get_path() if character_controller else NodePath()
	set(new_character_controller_path):
		_character_controller_path = new_character_controller_path
		if character_controller or _character_controller_path.is_empty(): return
		await get_tree().process_frame
		character_controller = get_node(_character_controller_path)

func _ready() -> void:
	if Engine.is_editor_hint(): return
	_check_disabled()
	_collect_input()

func _physics_process(delta: float) -> void:
	if Engine.is_editor_hint(): return
	_collect_input()
	if is_disabled: return
	_apply_input_direction_to_character_controller(delta)
	_camera.frame_node(character_controller)
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

func _apply_input_direction_to_character_controller(delta: float) -> void:
	assert(character_controller)
	var move_speed: float = character.move_speed
	var acceleration: float = character.acceleration * delta
	var velocity: Vector3 = character_controller.velocity
	if input_direction:
		var adjusted_input_direction: Vector2 = _camera.get_adjusted_movement(input_direction)
		velocity.x = move_toward(velocity.x, adjusted_input_direction.x * move_speed, acceleration)
		velocity.z = move_toward(velocity.z, adjusted_input_direction.y * move_speed, acceleration)
	else:
		velocity.x = move_toward(velocity.x, 0.0, acceleration)
		velocity.z = move_toward(velocity.z, 0.0, acceleration)
	character_controller.velocity = velocity

func _check_disabled() -> void:
	if Engine.is_editor_hint(): return
	is_disabled = not character_controller

func _get_configuration_warnings() -> PackedStringArray:
	var warnings: PackedStringArray = [ ]
	if not _camera: warnings.append("Missing Camera reference.")
	if not _agent: warnings.append("Missing Agent reference.")
	if not _interaction_area: warnings.append("Missing InteractionArea reference.")
	return warnings
