@tool
class_name AgentStateMachine
extends StateMachine

@export_group("Configuration")
@export var agent: Agent
@export var character: Character
@export var hit_box: CharacterHitBox

@onready var _state: AgentState = _initial_state.new()

func get_state() -> AgentState:
	return _state

func set_state(state: State) -> void:
	assert(state is AgentState)
	_state = state
	_state._state_machine = self

func _get_configuration_warnings() -> PackedStringArray:
	var warnings: PackedStringArray = []
	if not agent: warnings.append("Missing Agent reference.")
	return warnings + super._get_configuration_warnings()
