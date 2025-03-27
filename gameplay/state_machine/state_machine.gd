@tool
@icon("uid://dlf5ckv713eok")
class_name StateMachine
extends Node

@export_group("Configuration")
@export var _initial_state: GDScript

## This is used for serialization purposes; serves otherwise no purpose
@warning_ignore("unused_private_class_variable")
var _serialized_state: Dictionary[StringName, Variant]:
	get: return _get_state().serialize()
	set(new_serialized_state):
		var new_sate: State = State.from_serialized_state(new_serialized_state)
		_set_state(new_sate.deserialize(new_serialized_state, self))
		_get_state().enter(self)

func script_is_valid_state(script: Script) -> bool:
	if script.get_global_name() == "State": return true
	if script_is_valid_state(script.get_base_script()): return true
	return false

func _ready() -> void:
	if Engine.is_editor_hint(): return
	_get_state().enter(self)

func _process(delta: float) -> void:
	if Engine.is_editor_hint(): return
	_get_state().update(delta)

func _physics_process(delta: float) -> void:
	if Engine.is_editor_hint(): return
	_get_state().physics_update(delta)

func _unhandled_input(event: InputEvent) -> void:
	if Engine.is_editor_hint(): return
	_get_state().handle_input(event)

func _transition_to_next_state(target_state: State) -> void:
	_get_state().exit()
	var previous_state: State = _get_state()
	_set_state(target_state)
	_get_state().finished.connect(_transition_to_next_state)
	_get_state().enter(self, previous_state)

func _get_state() -> State:
	assert(false, "StateMachine._get_state is 'virtual' and needs to be overriden!")
	return null

func _set_state(_state: State) -> void:
	assert(false, "StateMachine._set_state is 'virtual' and needs to be overriden!")

func _get_configuration_warnings() -> PackedStringArray:
	var warnings: PackedStringArray = [ ]
	if not _initial_state: warnings.append("Missing initial state.")
	if not script_is_valid_state(_initial_state): warnings.append("Initial state is not a State.")
	return warnings
