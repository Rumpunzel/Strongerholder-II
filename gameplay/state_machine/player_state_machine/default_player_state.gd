@tool
class_name DefaultPlayerState
extends PlayerState

@export_group("Configuration")
@export var _haunt_timer: Timer

func enter(_previous_state_path: String, _data: Dictionary = { }) -> void:
	pass

func update(_delta: float) -> void:
	if not player.available_action: return
	if player.available_action.is_action_just_pressed():
		_haunt_timer.start(player.available_action.type.charge_time)
	if player.available_action.is_action_just_released():
		_haunt_timer.stop()

func physics_update(delta: float) -> void:
	player.update_character_controller(delta)

func handle_input(_event: InputEvent) -> void:
	pass

func exit() -> void:
	_haunt_timer.stop()

func _on_haunt_timer_timeout() -> void:
	assert(player.available_action)
	var date: Dictionary = {
		HAUNTED: player.available_action.target,
		HAUNTING: player.character_controller,
	}
	finished.emit(STATE_HAUNTING, date)

func _get_configuration_warnings() -> PackedStringArray:
	var warnings: PackedStringArray = [ ]
	if not _haunt_timer: warnings.append("Missing Timer reference.")
	return warnings + super._get_configuration_warnings()
