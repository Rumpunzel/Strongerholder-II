@icon("uid://bacbwgwwmvm5i")
class_name PlayerStateHaunting
extends PlayerState

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
	interaction_area.characters_to_ignore_areas_from.append(_haunted_character)
	interaction_area.reevaluate_hit_boxes_in_area()
	haunt_phantom_camera.append_follow_targets(_haunted_character)
	haunt_phantom_camera.priority = get_active_camera_priority()
	_haunting_character.haunt.rpc(_haunted_character_path)
	super.enter(state_machine, previous_state)

func update(_delta: float) -> void:
	var interaction_input: StringName = get_interaction_input()
	if interaction_input == "unhaunt":
		finished.emit(PlayerStateDefault.new())
		return
	var available_action: CharacterInteraction = get_available_action()
	if not available_action: return
	if available_action.is_action_just_pressed():
		_on_haunt_timer_timeout()
		#_haunt_timer.start(available_action.type.charge_time)
	#if available_action.is_action_just_released():
		#_haunt_timer.stop()

func physics_update(delta: float) -> void:
	assert(_haunted_character)
	assert(_haunting_character)
	var direction_input: Vector2 = get_direction_input()
	_haunted_character.apply_input_direction.rpc(direction_input, delta)
	_haunting_character.transform = _haunted_character.transform

func handle_input(_event: InputEvent) -> void:
	pass

func exit() -> void:
	assert(_haunted_character)
	assert(_haunting_character)
	interaction_area.characters_to_ignore_areas_from.erase(_haunted_character)
	interaction_area.reevaluate_hit_boxes_in_area()
	haunt_phantom_camera.erase_follow_targets(_haunted_character)
	haunt_phantom_camera.priority = get_default_camera_priority()
	_haunting_character.unhaunt.rpc(_haunted_character_path)

func serialize() -> Dictionary[StringName, Variant]:
	assert(_haunted_character)
	assert(_haunting_character)
	var serialized_state: Dictionary[StringName, Variant] = super.serialize()
	serialized_state[HAUNTED] = _haunted_character_path
	serialized_state[HAUNTING] = _haunting_character_path
	return serialized_state

func deserialize(serialized_state: Dictionary[StringName, Variant]) -> PlayerStateHaunting:
	super.deserialize(serialized_state)
	_haunted_character_path = serialized_state[HAUNTED]
	_haunting_character_path = serialized_state[HAUNTING]
	return self

func _on_haunt_timer_timeout() -> void:
	var available_action: CharacterInteraction = get_available_action()
	assert(available_action)
	finished.emit(PlayerStateHaunting.new(available_action.target.get_path(), _haunting_character_path))
