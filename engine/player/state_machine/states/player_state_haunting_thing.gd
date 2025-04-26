@icon("uid://bacbwgwwmvm5i")
class_name PlayerStateHauntingThing
extends PlayerState

# Data dictionary keys
const HAUNTED: StringName = "haunted"

var _haunted_path: NodePath

var _haunted: ThingHitBox

## Default parameters are required for deserialization to work
func _init(haunted_path: NodePath = NodePath()) -> void:
	_haunted_path = haunted_path

func enter(state_machine: StateMachine, previous_state: State = null) -> void:
	super.enter(state_machine, previous_state)
	var character: Character = get_character()
	character.visible = false
	character.disable_physics()
	_haunted = state_machine.get_node(_haunted_path)
	assert(_haunted)
	get_interaction_area().add_hit_box_to_ignore(_haunted)
	_haunted.haunt.rpc(character.get_path())
	get_haunt_phantom_camera().append_follow_targets(_haunted.thing)
	get_haunt_phantom_camera().priority = get_active_camera_priority()

func update(_delta: float) -> void:
	var interaction_input: StringName = get_interaction_input()
	if interaction_input == "unhaunt":
		finished.emit(PlayerStateDefault.new())
		return
	var available_interaction: Interaction = get_available_interaction()
	if not available_interaction: return
	if available_interaction.is_action_just_pressed():
		_on_haunt_timer_timeout()
		#_haunt_timer.start(available_action.type.charge_time)
	#if available_action.is_action_just_released():
		#_haunt_timer.stop()

func physics_update(delta: float) -> void:
	assert(_haunted)
	var direction_input: Vector2 = get_direction_input()
	var character: Character = get_character()
	var haunted_thing: Thing = _haunted.thing
	#_haunted.character.apply_input_direction.rpc(direction_input, delta)
	character.transform = _haunted.thing.transform

func handle_input(_event: InputEvent) -> void:
	pass

func exit() -> void:
	super.exit()
	assert(_haunted)
	get_interaction_area().remove_hit_box_to_ignore(_haunted)
	_haunted.unhaunt.rpc()
	var character: Character = get_character()
	character.enable_physics()
	character.visible = true
	get_haunt_phantom_camera().priority = get_default_camera_priority()
	get_haunt_phantom_camera().erase_follow_targets(_haunted.thing)

func serialize() -> Dictionary[StringName, Variant]:
	assert(_haunted)
	var serialized_state: Dictionary[StringName, Variant] = super.serialize()
	serialized_state[HAUNTED] = _haunted_path
	return serialized_state

func deserialize(serialized_state: Dictionary[StringName, Variant]) -> PlayerStateHauntingThing:
	super.deserialize(serialized_state)
	_haunted_path = serialized_state[HAUNTED]
	return self

func _on_haunt_timer_timeout() -> void:
	_haunt()
