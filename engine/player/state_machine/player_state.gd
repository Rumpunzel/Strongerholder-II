@icon("uid://c73t2rg8wrdt3")
class_name PlayerState
extends State

# Data dictionary keys
const HAUNTED: StringName = "haunted_character"
const HAUNTING: StringName = "haunting_character"

var player: Player

## Called by the state machine when receiving unhandled input events.
func handle_input(_event: InputEvent) -> void:
	pass

func get_character() -> Character: return player.character
func get_interaction_area() -> InteractionArea: return player.interaction_area

func get_default_phantom_camera() -> PhantomCamera3D: return player.default_phantom_camera
func get_haunt_phantom_camera() -> PhantomCamera3D: return player.haunt_phantom_camera

func get_active_camera_priority() -> int: return player.get_active_camera_priority()
func get_default_camera_priority() -> int: return player.get_default_camera_priority()

func get_direction_input() -> Vector2: return player.get_camera_adjusted_direction_input()
func get_interaction_input() -> StringName: return player.interaction_input
func get_available_action() -> CharacterInteraction: return player.available_action

func apply_input_direction(delta: float, to_character: Character = get_character()) -> void:
	if not to_character: return
	var move_speed: float = to_character.character_profile.move_speed
	var acceleration: float = to_character.character_profile.acceleration * delta
	var deceleration: float = to_character.character_profile.deceleration * delta
	var velocity: Vector3 = to_character.velocity
	var direction_input: Vector2 = get_direction_input()
	if direction_input:
		var adjusted_direction_input: Vector2 = direction_input
		velocity.x = move_toward(velocity.x, adjusted_direction_input.x * move_speed, acceleration)
		velocity.z = move_toward(velocity.z, adjusted_direction_input.y * move_speed, acceleration)
	else:
		velocity.x = move_toward(velocity.x, 0.0, deceleration)
		velocity.z = move_toward(velocity.z, 0.0, deceleration)
	to_character.velocity = velocity

# TODO: Pathfinding
