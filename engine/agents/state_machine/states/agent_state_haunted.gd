@icon("uid://cyxw8it04sxg5")
class_name AgentStateHaunted
extends AgentState

var _haunted_character_path: NodePath
var _haunting_character_path: NodePath

var _haunted_character: Character
var _haunting_character: Character

## Default parameters are required for deserialization to work
func _init(
	haunted_character_path: NodePath = NodePath(),
	haunting_character_path: NodePath = NodePath(),
) -> void:
	_haunted_character_path = haunted_character_path
	_haunting_character_path = haunting_character_path

func enter(state_machine: StateMachine, previous_state: State = null) -> void:
	_haunted_character = state_machine.get_node(_haunted_character_path)
	_haunting_character = state_machine.get_node(_haunting_character_path)
	assert(_haunted_character)
	assert(_haunting_character)
	_haunted_character.unhaunted.connect(_on_character_unhaunted)
	super.enter(state_machine, previous_state)

func update(_delta: float) -> void:
	pass

func handle_input(_event: InputEvent) -> void:
	pass

func exit() -> void:
	_haunted_character.unhaunted.disconnect(_on_character_unhaunted)

func serialize() -> Dictionary[StringName, Variant]:
	assert(_haunted_character)
	assert(_haunting_character)
	var serialized_state: Dictionary[StringName, Variant] = super.serialize()
	serialized_state[HAUNTED] = _haunted_character_path
	serialized_state[HAUNTING] = _haunting_character_path
	return serialized_state

func deserialize(serialized_state: Dictionary[StringName, Variant]) -> AgentStateHaunted:
	super.deserialize(serialized_state)
	_haunted_character_path = serialized_state[HAUNTED]
	_haunting_character_path = serialized_state[HAUNTING]
	return self

func _on_character_unhaunted(unhaunted_character: Character, _unhaunting_character: Character) -> void:
	if unhaunted_character != agent.character: return
	finished.emit(AgentStateDefault.new())
