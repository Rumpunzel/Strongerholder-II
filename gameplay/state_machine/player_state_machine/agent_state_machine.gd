@tool
class_name AgentStateMachine
extends StateMachine

@export_group("Configuration")
@export var _agent: Agent

@onready var _state: AgentState = _initial_state.new()

func _get_state() -> AgentState:
	_state.agent = _agent
	return _state

func _set_state(state: State) -> void:
	assert(state is AgentState)
	_state = state
	_state.agent = _agent

func _get_configuration_warnings() -> PackedStringArray:
	var warnings: PackedStringArray = [ ]
	if not _agent: warnings.append("Missing Agent reference.")
	return warnings + super._get_configuration_warnings()
