@tool
@icon("uid://dlf5ckv713eok")
class_name AgentStateMachine
extends Node

@export var _state: AgentState

@export_group("Configuration")
@export var _agent: Agent

func _ready() -> void:
	for state: AgentState in get_children():
		state.agent = _agent
		state.finished.connect(_transition_to_next_state)
	await _agent.ready
	_state.enter("")

func _process(delta: float) -> void:
	_state.update(delta)

func _physics_process(delta: float) -> void:
	_state.physics_update(delta)

func _unhandled_input(event: InputEvent) -> void:
	_state.handle_input(event)

func _transition_to_next_state(target_state_path: String, data: Dictionary = { }) -> void:
	if not has_node(target_state_path):
		printerr("%s: Trying to transition to state %s but it does not exist." % [owner.name, target_state_path])
		return
	var previous_state_path: String = _state.name
	_state.exit()
	_state = get_node(target_state_path)
	_state.enter(previous_state_path, data)

func _get_configuration_warnings() -> PackedStringArray:
	var warnings: PackedStringArray = [ ]
	if not _agent: warnings.append("Missing Agent reference.")
	return warnings
