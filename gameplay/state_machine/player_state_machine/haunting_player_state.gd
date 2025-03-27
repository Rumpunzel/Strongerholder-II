@tool
@icon("uid://bacbwgwwmvm5i")
class_name HauntingPlayerState
extends PlayerState

@export_group("Configuration")
@export var _haunt_timer: Timer

var _haunted_character_controller: CharacterController
var _haunting_character_controller: CharacterController

func enter(previous_state_path: String, data: Dictionary[String, Variant] = { }) -> void:
	assert(data.has_all([HAUNTED, HAUNTING]))
	assert(data.size() == 2)
	_haunted_character_controller = data[HAUNTED]
	_haunting_character_controller = data[HAUNTING]
	_haunting_character_controller.visible = false
	Gameplay.character_controller_haunted.emit(_haunted_character_controller, _haunting_character_controller)
	print("previous_state_path: %s" % previous_state_path)
	if previous_state_path.is_empty(): camera.frame_node(_haunted_character_controller, true)

func update(_delta: float) -> void:
	if interaction_input == "unpossess":
		finished.emit(STATE_DEFAULT)
		return
	if not available_action: return
	if available_action.is_action_just_pressed():
		_haunt_timer.start(available_action.type.charge_time)
	if available_action.is_action_just_released():
		_haunt_timer.stop()

func physics_update(delta: float) -> void:
	apply_input_direction(delta, _haunted_character_controller)
	_haunting_character_controller.transform = _haunted_character_controller.transform
	camera.frame_node(_haunted_character_controller)

func handle_input(_event: InputEvent) -> void:
	pass

func exit() -> void:
	_haunting_character_controller.visible = true
	Gameplay.character_controller_unhaunted.emit(_haunted_character_controller)

func serialize_data() -> Dictionary[String, Variant]:
	var serialized_data: Dictionary[String, Variant] = {
		HAUNTED: _haunted_character_controller.get_path(),
		HAUNTING: _haunting_character_controller.get_path(),
	}
	return serialized_data.merged(super.serialize_data())

func deserialize_data(serialized_data: Dictionary[String, Variant]) -> Dictionary[String, Variant]:
	var haunted_character_controller_node_path: NodePath = serialized_data[HAUNTED]
	var haunting_character_controller_node_path: NodePath = serialized_data[HAUNTING]
	var deserialized_data: Dictionary[String, Variant] = {
		HAUNTED: get_node(haunted_character_controller_node_path),
		HAUNTING: get_node(haunting_character_controller_node_path),
	}
	return deserialized_data.merged(super.deserialize_data(serialized_data))

func _on_haunt_timer_timeout() -> void:
	assert(available_action)
	_haunt_timer.stop()
	var data: Dictionary[String, Variant] = {
		HAUNTED: available_action.target,
		HAUNTING: _haunting_character_controller,
	}
	finished.emit(STATE_HAUNTING, data)

func _get_configuration_warnings() -> PackedStringArray:
	var warnings: PackedStringArray = [ ]
	if not _haunt_timer: warnings.append("Missing Timer reference.")
	return warnings + super._get_configuration_warnings()
