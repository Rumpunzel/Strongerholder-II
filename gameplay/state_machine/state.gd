@tool
@icon("uid://cawf6uult17mx")
class_name State
extends Node

const NAME: StringName = "name"
const DATA: StringName = "data"

## Emitted when the state finishes and wants to transition to another state.
@warning_ignore("unused_signal")
signal finished(next_state_path: String, data: Dictionary)

## Called by the state machine upon changing the active state.
## The [param data] parameter is a dictionary with arbitrary data the state can use to initialize itself.
func enter(_previous_state_path: String, _data: Dictionary = { }) -> void:
	pass

## Called by the state machine on the engine's main loop tick.
func update(_delta: float) -> void:
	pass

## Called by the state machine on the engine's physics update tick.
func physics_update(_delta: float) -> void:
	pass

## Called by the state machine when receiving unhandled input events.
func handle_input(_event: InputEvent) -> void:
	pass

## Called by the state machine before changing the active state.
func exit() -> void:
	pass

func serialize_data() -> Dictionary[String, Variant]:
	return { }

func deserialize_data(_serialized_data: Dictionary[String, Variant]) -> Dictionary[String, Variant]:
	return { }

func _get_configuration_warnings() -> PackedStringArray:
	var warnings: PackedStringArray = [ ]
	return warnings
