@tool
@icon("uid://bacbwgwwmvm5i")
class_name HauntingPlayerState
extends PlayerState

@export_group("Configuration")
@export var _haunt_timer: Timer

var _haunted_character_controller: CharacterController
var _haunting_character_controller: CharacterController

func enter(_previous_state_path: String, data: Dictionary = { }) -> void:
	assert(data.has_all([HAUNTED, HAUNTING]))
	assert(data.size() == 2)
	_haunted_character_controller = data[HAUNTED]
	player.haunt_character_controller(_haunted_character_controller)
	_haunting_character_controller = data[HAUNTING]
	_haunting_character_controller.visible = false
	Gameplay.character_controller_haunted.emit(_haunted_character_controller, _haunting_character_controller)

func update(_delta: float) -> void:
	if player.interaction_input == "unpossess":
		finished.emit(DEFAULT_STATE)
	if not player.available_action: return
	if player.available_action.is_action_just_pressed():
		_haunt_timer.start(player.available_action.type.charge_time)
	if player.available_action.is_action_just_released():
		_haunt_timer.stop()

func physics_update(delta: float) -> void:
	player.update_character_controller(delta)
	_haunting_character_controller.transform = _haunted_character_controller.transform

func handle_input(_event: InputEvent) -> void:
	pass

func exit() -> void:
	_haunting_character_controller.visible = true
	player.unhaunt_character_controller(_haunting_character_controller)

func _on_haunt_timer_timeout() -> void:
	assert(player.available_action)
	_haunt_timer.stop()
	var data: Dictionary = {
		HAUNTED: player.available_action.target,
		HAUNTING: _haunting_character_controller,
	}
	finished.emit(HAUNTING_STATE, data)

func _get_configuration_warnings() -> PackedStringArray:
	var warnings: PackedStringArray = [ ]
	if not _haunt_timer: warnings.append("Missing Timer reference.")
	return warnings + super._get_configuration_warnings()
