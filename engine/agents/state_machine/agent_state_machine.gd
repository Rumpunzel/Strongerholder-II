@tool
class_name AgentStateMachine
extends StateMachine

@export_group("Configuration")
@export var _agent: Agent
@export var _character: Character
@export var _hurt_box: CharacterHurtBox

@onready var _state: AgentState = _initial_state.new()

func _get_state() -> AgentState:
	if _state: _setup_state()
	return _state

func _set_state(state: State) -> void:
	assert(state is AgentState)
	_state = state
	_setup_state()

func _setup_state() -> void:
	_state.agent = _agent
	_state.character = _character
	_state.hurt_box = _hurt_box

func _get_configuration_warnings() -> PackedStringArray:
	var warnings: PackedStringArray = [ ]
	if not _agent: warnings.append("Missing Agent reference.")
	return warnings + super._get_configuration_warnings()
