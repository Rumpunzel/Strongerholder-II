@tool
@icon("uid://dlf5ckv713eok")
class_name PlayerStateMachine
extends StateMachine

@export var _state: PlayerState

@export_group("Configuration")
@export var _player: Player

## This is used for serialization purposes; serves otherwise no purpose
var _serialized_state: Dictionary[StringName, Variant]:
	get: return { State.NAME: _state.name, State.DATA: _state.serialize_data() }
	set(new_serialized_state):
		print("%s new serialized data: %s" % [_player.name, new_serialized_state])
		print("%s old serialized data: %s" % [_player.name, _serialized_state])
		if new_serialized_state == _serialized_state: return
		var state_name: String = new_serialized_state[State.NAME]
		print("state_name: %s" % state_name)
		if state_name.is_empty(): return
		_state = get_node(state_name)
		var serialized_data: Dictionary[String, Variant] = new_serialized_state[State.DATA]
		var data: Dictionary[String, Variant] = _state.deserialize_data(serialized_data)
		print("entering state: %s" % serialized_data)
		_state.enter("", data)

func _ready() -> void:
	if Engine.is_editor_hint(): return
	for state: PlayerState in find_children("*", "PlayerState"):
		state.player = _player
	super._ready()

func _process(delta: float) -> void:
	if Engine.is_editor_hint(): return
	_state.update(delta)

func _physics_process(delta: float) -> void:
	if Engine.is_editor_hint(): return
	_state.physics_update(delta)

func _unhandled_input(event: InputEvent) -> void:
	if Engine.is_editor_hint(): return
	_state.handle_input(event)

func _transition_to_next_state(target_state_path: String, data: Dictionary[String, Variant] = { }) -> void:
	if not has_node(target_state_path):
		printerr("%s: Trying to transition to state %s but it does not exist." % [owner.name, target_state_path])
		return
	_state.exit()
	_state = get_node(target_state_path)
	var previous_state_path: String = _state.name
	_state.enter(previous_state_path, data)

func _get_configuration_warnings() -> PackedStringArray:
	var warnings: PackedStringArray = [ ]
	if not _player: warnings.append("Missing Player reference.")
	return warnings
