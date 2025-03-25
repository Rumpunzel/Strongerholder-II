@tool
@icon("uid://dlf5ckv713eok")
class_name StateMachine
extends Node

@export_group("Configuration")

func _ready() -> void:
	for state: State in get_children():
		state.finished.connect(_transition_to_next_state)

func _process(_delta: float) -> void:
	assert(false, "StateMachine._process needs to be overriden!")

func _physics_process(_delta: float) -> void:
	assert(false, "StateMachine._physics_process needs to be overriden!")

func _unhandled_input(_event: InputEvent) -> void:
	assert(false, "StateMachine._unhandled_input needs to be overriden!")

func _transition_to_next_state(target_state_path: String, data: Dictionary = { }) -> void:
	assert(false, "StateMachine._transition_to_next_state is 'abstract' and needs to be overriden!")

func _get_configuration_warnings() -> PackedStringArray:
	var warnings: PackedStringArray = [ ]
	return warnings
