@tool
@icon("uid://dlf5ckv713eok")
class_name StateMachine
extends Node

@export_group("Configuration")
@export var _initial_state: GDScript

## This is used for serialization purposes; serves otherwise no purpose
@warning_ignore("unused_private_class_variable")
var _serialized_state: Dictionary[StringName, Variant]:
	get: return get_state().serialize()
	set(new_serialized_state):
		stop()
		var new_sate: State = State.from_serialized_state(new_serialized_state)
		#if not is_node_ready(): await ready
		set_state(new_sate.deserialize(new_serialized_state))
		start()

func _ready() -> void:
	var initial_state: State = _initial_state.new()
	set_state(initial_state)

func script_is_valid_state(script: Script) -> bool:
	if script.get_global_name() == "State": return true
	if script_is_valid_state(script.get_base_script()): return true
	return false

func start() -> void:
	if not is_node_ready(): await ready
	get_state().enter(self)

## Called by the state machine on the engine's main loop tick.
func update(delta: float) -> void:
	get_state().update(delta)

## Called by the state machine on the engine's physics update tick.
func physics_update(delta: float) -> void:
	get_state().physics_update(delta)

func stop() -> void:
	var state: State = get_state()
	if not state: return
	state.exit()

func transition_to_next_state(target_state: State) -> void:
	get_state().exit()
	var previous_state: State = get_state()
	set_state(target_state)
	get_state().enter(self, previous_state)

func get_state() -> State:
	assert(false, "StateMachine._get_state is 'virtual' and needs to be overriden!")
	return null

func set_state(_state: State) -> void:
	assert(false, "StateMachine._set_state is 'virtual' and needs to be overriden!")

func _get_configuration_warnings() -> PackedStringArray:
	var warnings: PackedStringArray = [ ]
	if not _initial_state: warnings.append("Missing initial state.")
	if not script_is_valid_state(_initial_state): warnings.append("Initial state is not a State.")
	return warnings
