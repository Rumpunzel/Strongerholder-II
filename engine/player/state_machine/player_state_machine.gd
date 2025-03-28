@tool
class_name PlayerStateMachine
extends StateMachine

@export_group("Configuration")
@export var _player: Player

@onready var _state: PlayerState = _initial_state.new()

## Called by the state machine when receiving unhandled input events.
func handle_input(event: InputEvent) -> void:
	_get_state().handle_input(event)

func _get_state() -> PlayerState:
	_state.player = _player
	return _state

func _set_state(state: State) -> void:
	assert(state is PlayerState)
	_state = state
	_state.player = _player

func _get_configuration_warnings() -> PackedStringArray:
	var warnings: PackedStringArray = [ ]
	if not _player: warnings.append("Missing Player reference.")
	return warnings + super._get_configuration_warnings()
