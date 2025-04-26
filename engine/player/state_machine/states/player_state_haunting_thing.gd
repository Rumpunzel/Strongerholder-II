@icon("uid://bacbwgwwmvm5i")
class_name PlayerStateHauntingThing
extends PlayerState

# Data dictionary keys
const HAUNTED: StringName = "haunted"

var _haunted_path: NodePath

var _haunted: ThingHitBox
var _haunt_camera: PhantomCamera3D

## Default parameters are required for deserialization to work
func _init(haunted_path: NodePath = NodePath()) -> void:
	_haunted_path = haunted_path

func enter(state_machine: StateMachine, previous_state: State = null) -> void:
	super.enter(state_machine, previous_state)
	var character: Character = get_character()
	_haunted = state_machine.get_node(_haunted_path)
	assert(_haunted)
	var haunted_thing: Thing = _haunted.thing
	assert(haunted_thing)
	character.visible = false
	character.position = haunted_thing.position
	get_interaction_area().add_hit_box_to_ignore(_haunted)
	_haunted.haunt.rpc(character.get_path())
	haunted_thing.add_constant_torque(Vector3.UP)
	_haunt_camera = _create_haunt_camera()
	_haunt_camera.append_follow_targets(haunted_thing)
	_haunt_camera.append_look_at_target(haunted_thing)

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
	var distance_force: Vector3 = character.get_heads_up_anchor() - haunted_thing.position
	var horizontal_offset: Vector2 = Vector2(distance_force.x, distance_force.z)
	var adjusted_direction_input: Vector2 = direction_input / maxf(horizontal_offset.length(), 1.0)
	character.apply_input_direction.rpc(adjusted_direction_input, delta)
	haunted_thing.apply_input_direction.rpc(adjusted_direction_input, character.profile.mass * distance_force)

func handle_input(_event: InputEvent) -> void:
	pass

func exit() -> void:
	super.exit()
	assert(_haunted)
	var character: Character = get_character()
	var haunted_thing: Thing = _haunted.thing
	assert(haunted_thing)
	get_interaction_area().remove_hit_box_to_ignore(_haunted)
	character.position = haunted_thing.position
	character.velocity = haunted_thing.linear_velocity * haunted_thing.mass / character.profile.mass
	haunted_thing.add_constant_torque(Vector3.ZERO)
	_haunted.unhaunt.rpc()
	character.visible = true
	_haunt_camera.queue_free()

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
