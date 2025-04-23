@icon("uid://cyxw8it04sxg5")
class_name HauntedAgentState
extends AgentState

const HAUNTED_MATERIAL: Material = preload("uid://cmbf2wnye66jw")

var _haunted_character: Character
var _haunting_character: Character

## Default parameters are required for deserialization to work
func _init(
	haunted_character: Character = null,
	haunting_character: Character = null,
) -> void:
	_haunted_character = haunted_character
	_haunting_character = haunting_character

func enter(state_machine: StateMachine, previous_state: State = null) -> void:
	assert(_haunted_character)
	assert(_haunting_character)
	_haunted_character.character_model.apply_material_overlay(HAUNTED_MATERIAL)
	_haunted_character.unhaunted.connect(_on_character_unhaunted)
	super.enter(state_machine, previous_state)

func update(_delta: float) -> void:
	pass

func handle_input(_event: InputEvent) -> void:
	pass

func exit() -> void:
	_haunted_character.character_model.apply_material_overlay(null)
	_haunted_character.unhaunted.disconnect(_on_character_unhaunted)

func serialize() -> Dictionary[StringName, Variant]:
	var serialized_state: Dictionary[StringName, Variant] = super.serialize()
	serialized_state[HAUNTED] = _haunted_character.get_path()
	serialized_state[HAUNTING] = _haunting_character.get_path()
	return serialized_state

func deserialize(serialized_state: Dictionary[StringName, Variant], state_machine: StateMachine) -> HauntedAgentState:
	var state: HauntedAgentState = super.deserialize(serialized_state, state_machine)
	var haunted_character_node_path: NodePath = serialized_state[HAUNTED]
	var haunting_character_node_path: NodePath = serialized_state[HAUNTING]
	state._haunted_character = state_machine.get_node(haunted_character_node_path)
	state._haunting_character = state_machine.get_node(haunting_character_node_path)
	return state

func _on_character_unhaunted(unhaunted_character: Character, _unhaunting_character: Character) -> void:
	if unhaunted_character != agent.character: return
	finished.emit(DefaultAgentState.new())
