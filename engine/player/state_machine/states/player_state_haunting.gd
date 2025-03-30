@icon("uid://bacbwgwwmvm5i")
class_name HauntingPlayerState
extends PlayerState

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
	_haunting_character.visible = false
	interaction_area.characters_to_ignore_areas_from.append(_haunted_character)
	interaction_area.reevaluate_hit_boxes_in_area()
	haunt_phantom_camera.append_follow_targets(_haunted_character)
	haunt_phantom_camera.priority = get_active_camera_priority()
	Game.character_haunted.emit(_haunted_character, _haunting_character)
	super.enter(state_machine, previous_state)

func update(_delta: float) -> void:
	var interaction_input: StringName = get_interaction_input()
	if interaction_input == "unhaunt":
		finished.emit(DefaultPlayerState.new())
		return
	var available_action: CharacterInteraction = get_available_action()
	if not available_action: return
	if available_action.is_action_just_pressed():
		_on_haunt_timer_timeout()
		#_haunt_timer.start(available_action.type.charge_time)
	#if available_action.is_action_just_released():
		#_haunt_timer.stop()

func physics_update(delta: float) -> void:
	apply_input_direction(delta, _haunted_character)
	_haunting_character.transform = _haunted_character.transform

func handle_input(_event: InputEvent) -> void:
	pass

func exit() -> void:
	_haunting_character.visible = true
	interaction_area.characters_to_ignore_areas_from.erase(_haunted_character)
	interaction_area.reevaluate_hit_boxes_in_area()
	haunt_phantom_camera.erase_follow_targets(_haunted_character)
	haunt_phantom_camera.priority = get_default_camera_priority()
	Game.character_unhaunted.emit(_haunted_character)

func serialize() -> Dictionary[StringName, Variant]:
	var serialized_state: Dictionary[StringName, Variant] = super.serialize()
	serialized_state[HAUNTED] = _haunted_character.get_path()
	serialized_state[HAUNTING] = _haunting_character.get_path()
	return serialized_state

func deserialize(serialized_state: Dictionary[StringName, Variant], state_machine: StateMachine) -> HauntingPlayerState:
	var state: HauntingPlayerState = super.deserialize(serialized_state, state_machine)
	var haunted_character_node_path: NodePath = serialized_state[HAUNTED]
	var haunting_character_node_path: NodePath = serialized_state[HAUNTING]
	state._haunted_character = state_machine.get_node(haunted_character_node_path)
	state._haunting_character = state_machine.get_node(haunting_character_node_path)
	return state

func _on_haunt_timer_timeout() -> void:
	var available_action: CharacterInteraction = get_available_action()
	assert(available_action)
	finished.emit(HauntingPlayerState.new(available_action.target, _haunting_character))
