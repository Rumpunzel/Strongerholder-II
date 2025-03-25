@tool
class_name DefaultAgentState
extends AgentState

@export_group("Configuration")

func enter(_previous_state_path: String, _data: Dictionary = { }) -> void:
	Gameplay.character_controller_haunted.connect(_on_character_controller_haunted)

func update(_delta: float) -> void:
	pass

func physics_update(_delta: float) -> void:
	pass

func handle_input(_event: InputEvent) -> void:
	pass

func exit() -> void:
	Gameplay.character_controller_haunted.disconnect(_on_character_controller_haunted)

func _on_character_controller_haunted(haunted_character_controller: CharacterController, haunting_character_controller: CharacterController) -> void:
	if haunted_character_controller != agent.character_controller: return
	var data: Dictionary = {
		HAUNTED: haunted_character_controller,
		HAUNTING: haunting_character_controller,
	}
	finished.emit(HAUNTED_STATE, data)

func _get_configuration_warnings() -> PackedStringArray:
	var warnings: PackedStringArray = [ ]
	return warnings + super._get_configuration_warnings()
