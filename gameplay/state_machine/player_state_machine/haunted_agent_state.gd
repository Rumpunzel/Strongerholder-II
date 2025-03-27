@tool
@icon("uid://cyxw8it04sxg5")
class_name HauntedState
extends AgentState

@export_group("Configuration")
@export var _haunted_material: Material = preload("uid://cmbf2wnye66jw")

var _haunted_character_controller: CharacterController
var _haunting_character_controller: CharacterController

func enter(_previous_state_path: String, data: Dictionary[String, Variant] = {}) -> void:
	assert(data.has_all(["haunting_character_controller", "haunted_character_controller"]))
	assert(data.size() == 2)
	_haunted_character_controller = data[HAUNTED]
	_haunted_character_controller.character_model.apply_material_overlay(_haunted_material)
	_haunting_character_controller = data[HAUNTING]
	Gameplay.character_controller_unhaunted.connect(_on_character_controller_unhaunted)

func update(_delta: float) -> void:
	pass

func handle_input(_event: InputEvent) -> void:
	pass

func exit() -> void:
	_haunted_character_controller.character_model.apply_material_overlay(null)
	Gameplay.character_controller_unhaunted.disconnect(_on_character_controller_unhaunted)

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

func _on_character_controller_unhaunted(unhaunted_character_controller: CharacterController) -> void:
	if unhaunted_character_controller != agent.character_controller: return
	finished.emit(STATE_DEFAULT)

func _get_configuration_warnings() -> PackedStringArray:
	var warnings: PackedStringArray = []
	if not _haunted_material: warnings.append("Missing haunted material.")
	return warnings + super._get_configuration_warnings()
