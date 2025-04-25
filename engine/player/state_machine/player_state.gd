@icon("uid://c73t2rg8wrdt3")
class_name PlayerState
extends State

var player_ghost: PlayerGhost
var input_reader: InputReader
var character: Character
var hurt_box: CharacterHurtBox
var interaction_area: InteractionArea
var default_phantom_camera: PhantomCamera3D
var haunt_phantom_camera: PhantomCamera3D

## Called by the state machine when receiving unhandled input events.
func handle_input(_event: InputEvent) -> void:
	pass

func get_active_camera_priority() -> int: return player_ghost.get_active_camera_priority()
func get_default_camera_priority() -> int: return player_ghost.get_default_camera_priority()

func get_direction_input() -> Vector2: return input_reader.get_camera_adjusted_direction_input()
func get_interaction_input() -> StringName: return input_reader.interaction_input
func get_available_action() -> Interaction: return interaction_area.available_action

func _haunt() -> void:
	var available_action: Interaction = get_available_action()
	assert(available_action)
	if available_action is CharacterInteraction: _haunt_character(available_action as CharacterInteraction)
	elif available_action is ThingInteraction: _haunt_thing(available_action as ThingInteraction)

func _haunt_character(action: CharacterInteraction) -> void:
	assert(action)
	assert(action is CharacterInteraction)
	finished.emit(PlayerStateHauntingCharacter.new(action.target.get_path()))

func _haunt_thing(action: ThingInteraction) -> void:
	assert(action)
	assert(action is ThingInteraction)
	finished.emit(PlayerStateHauntingThing.new(action.target.get_path()))
