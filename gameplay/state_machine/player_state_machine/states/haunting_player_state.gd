@icon("uid://bacbwgwwmvm5i")
class_name HauntingPlayerState
extends PlayerState

var _haunted_character_controller: CharacterController
var _haunting_character_controller: CharacterController

## Default parameters are required for deserialization to work
func _init(
	haunted_character_controller: CharacterController = null,
	haunting_character_controller: CharacterController = null,
) -> void:
	_haunted_character_controller = haunted_character_controller
	_haunting_character_controller = haunting_character_controller

func enter(state_machine: StateMachine, previous_state: State = null) -> void:
	_haunting_character_controller.visible = false
	interaction_area.character_controllers_to_ignore_areas_from.append(_haunted_character_controller)
	camera.frame_node(_haunted_character_controller, true)
	Gameplay.character_controller_haunted.emit(_haunted_character_controller, _haunting_character_controller)
	super.enter(state_machine, previous_state)

func update(_delta: float) -> void:
	if interaction_input == "unpossess":
		finished.emit(DefaultPlayerState.new())
		return
	if not available_action: return
	if available_action.is_action_just_pressed():
		_on_haunt_timer_timeout()
		#_haunt_timer.start(available_action.type.charge_time)
	#if available_action.is_action_just_released():
		#_haunt_timer.stop()

func physics_update(delta: float) -> void:
	apply_input_direction(delta, _haunted_character_controller)
	_haunting_character_controller.transform = _haunted_character_controller.transform
	camera.frame_node(_haunted_character_controller)

func handle_input(_event: InputEvent) -> void:
	pass

func exit() -> void:
	_haunting_character_controller.visible = true
	interaction_area.character_controllers_to_ignore_areas_from.erase(_haunted_character_controller)
	Gameplay.character_controller_unhaunted.emit(_haunted_character_controller)

func serialize() -> Dictionary[StringName, Variant]:
	var serialized_state: Dictionary[StringName, Variant] = super.serialize()
	serialized_state[HAUNTED] = _haunted_character_controller.get_path()
	serialized_state[HAUNTING] = _haunting_character_controller.get_path()
	return serialized_state

func deserialize(serialized_state: Dictionary[StringName, Variant], state_machine: StateMachine) -> HauntingPlayerState:
	var state: HauntingPlayerState = super.deserialize(serialized_state, state_machine)
	var haunted_character_controller_node_path: NodePath = serialized_state[HAUNTED]
	var haunting_character_controller_node_path: NodePath = serialized_state[HAUNTING]
	print("haunted_character_controller_node_path: %s" % haunted_character_controller_node_path)
	print("haunting_character_controller_node_path: %s" % haunting_character_controller_node_path)
	state._haunted_character_controller = state_machine.get_node(haunted_character_controller_node_path)
	state._haunting_character_controller = state_machine.get_node(haunting_character_controller_node_path)
	print("state._haunted_character_controller: %s" % state._haunted_character_controller)
	print("state._haunting_character_controller: %s" % state._haunting_character_controller)
	return state

func _on_haunt_timer_timeout() -> void:
	assert(available_action)
	finished.emit(HauntingPlayerState.new(available_action.target, _haunting_character_controller))
