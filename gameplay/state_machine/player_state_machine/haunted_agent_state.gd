@icon("uid://cyxw8it04sxg5")
class_name HauntedAgentState
extends AgentState

const HAUNTED_MATERIAL: Material = preload("uid://cmbf2wnye66jw")

var _haunted_character_controller: CharacterController
var _haunting_character_controller: CharacterController

## Default parameters are required for deserialization to work
func _init(
	haunted_character_controller: CharacterController = null,
	haunting_character_controller: CharacterController = null,
) -> void:
	_haunted_character_controller = haunted_character_controller
	_haunting_character_controller = haunting_character_controller
	Gameplay.character_controller_unhaunted.connect(_on_character_controller_unhaunted)

static func from_serialized_state(serialized_state: Dictionary[StringName, Variant], any_node: Node) -> HauntedAgentState:
	var state: HauntedAgentState = super.from_serialized_state(serialized_state, any_node)
	var haunted_character_controller_node_path: NodePath = serialized_state[HAUNTED]
	var haunting_character_controller_node_path: NodePath = serialized_state[HAUNTING]
	state._haunted_character_controller = any_node.get_node(haunted_character_controller_node_path)
	state._haunting_character_controller = any_node.get_node(haunting_character_controller_node_path)
	return state

func enter(previous_state: State = null) -> void:
	assert(_haunted_character_controller)
	assert(_haunting_character_controller)
	_haunted_character_controller.character_model.apply_material_overlay(HAUNTED_MATERIAL)
	super.enter(previous_state)

func update(_delta: float) -> void:
	pass

func handle_input(_event: InputEvent) -> void:
	pass

func exit() -> void:
	_haunted_character_controller.character_model.apply_material_overlay(null)
	Gameplay.character_controller_unhaunted.disconnect(_on_character_controller_unhaunted)

func serialize() -> Dictionary[StringName, Variant]:
	var serialized_state: Dictionary[StringName, Variant] = super.serialize()
	serialized_state[HAUNTED] = _haunted_character_controller.get_path()
	serialized_state[HAUNTING] = _haunting_character_controller.get_path()
	return serialized_state

func _on_character_controller_unhaunted(unhaunted_character_controller: CharacterController) -> void:
	if unhaunted_character_controller != agent.character_controller: return
	finished.emit(DefaultAgentState.new())
