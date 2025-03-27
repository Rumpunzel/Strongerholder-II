@tool
class_name DefaultPlayerState
extends PlayerState

@export_group("Configuration")
@export var _haunt_timer: Timer

func enter(_previous_state_path: String, _data: Dictionary[String, Variant] = { }) -> void:
	pass

func update(_delta: float) -> void:
	if not available_action: return
	if available_action.is_action_just_pressed():
		_haunt_timer.start(available_action.type.charge_time)
	if available_action.is_action_just_released():
		_haunt_timer.stop()

func physics_update(delta: float) -> void:
	apply_input_direction(delta)
	camera.frame_node(character_controller)

func handle_input(_event: InputEvent) -> void:
	pass

func exit() -> void:
	_haunt_timer.stop()

func _on_haunt_timer_timeout() -> void:
	assert(available_action)
	var date: Dictionary[String, Variant] = {
		HAUNTED: available_action.target,
		HAUNTING: character_controller,
	}
	finished.emit(STATE_HAUNTING, date)

func _get_configuration_warnings() -> PackedStringArray:
	var warnings: PackedStringArray = [ ]
	if not _haunt_timer: warnings.append("Missing Timer reference.")
	return warnings + super._get_configuration_warnings()
