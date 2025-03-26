@tool
@icon("uid://cyxw8it04sxg5")
class_name HauntedState
extends AgentState

@export_group("Configuration")
@export var _haunted_material: Material = preload("uid://cmbf2wnye66jw")

var _haunted_character_controller: CharacterController
var _haunting_character_controller: CharacterController

func enter(_previous_state_path: String, data: Dictionary = {}) -> void:
	assert(data.has_all(["haunting_character_controller", "haunted_character_controller"]))
	assert(data.size() == 2)
	_haunted_character_controller = data.haunted_character_controller
	_haunted_character_controller.character_model.apply_material_overlay(_haunted_material)
	_haunting_character_controller = data.haunting_character_controller
	Gameplay.character_controller_unhaunted.connect(_on_character_controller_unhaunted)

func update(_delta: float) -> void:
	pass

func handle_input(_event: InputEvent) -> void:
	pass

func exit() -> void:
	_haunted_character_controller.character_model.apply_material_overlay(null)
	Gameplay.character_controller_unhaunted.disconnect(_on_character_controller_unhaunted)

func _on_character_controller_unhaunted(unhaunted_character_controller: CharacterController) -> void:
	if unhaunted_character_controller != agent.character_controller: return
	finished.emit(STATE_DEFAULT)

func _get_configuration_warnings() -> PackedStringArray:
	var warnings: PackedStringArray = []
	if not _haunted_material: warnings.append("Missing haunted material.")
	return warnings + super._get_configuration_warnings()
