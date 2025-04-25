@tool
class_name PlayerStateMachine
extends StateMachine

@export_group("Configuration")
@export var _player_ghost: PlayerGhost
@export var _input_reader: InputReader
@export var _character: Character
@export var _hit_box: CharacterHitBox
@export var _interaction_area: InteractionArea
@export var _default_phantom_camera: PhantomCamera3D
@export var _haunt_phantom_camera: PhantomCamera3D

@onready var _state: PlayerState = _initial_state.new()

## Called by the state machine when receiving unhandled input events.
func handle_input(event: InputEvent) -> void:
	_get_state().handle_input(event)

func _get_state() -> PlayerState:
	if _state: _setup_state()
	return _state

func _set_state(state: State) -> void:
	assert(state is PlayerState)
	_state = state
	_setup_state()

func _setup_state() -> void:
	_state.player_ghost = _player_ghost
	_state.input_reader = _input_reader
	_state.character = _character
	_state.hit_box = _hit_box
	_state.interaction_area = _interaction_area
	_state.default_phantom_camera = _default_phantom_camera
	_state.haunt_phantom_camera = _haunt_phantom_camera

func _get_configuration_warnings() -> PackedStringArray:
	var warnings: PackedStringArray = []
	if not _player_ghost: warnings.append("Missing PlayerGhost reference.")
	if not _input_reader: warnings.append("Missing InputReader reference.")
	if not _interaction_area: warnings.append("Missing InteractionArea reference.")
	if not _default_phantom_camera: warnings.append("Missing default PhantomCamera3D reference.")
	if not _haunt_phantom_camera: warnings.append("Missing haunt PhantomCamera3D reference.")
	return warnings + super._get_configuration_warnings()
