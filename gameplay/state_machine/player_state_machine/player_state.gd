@tool
@icon("uid://c73t2rg8wrdt3")
class_name PlayerState
extends State

const STATE_DEFAULT: StringName = "Default"
const STATE_HAUNTED: StringName = "Haunted"
const STATE_HAUNTING: StringName = "Haunting"

# Data dictionary keys
const HAUNTED: StringName = "haunted_character_controller"
const HAUNTING: StringName = "haunting_character_controller"

var player: Player

var character_controller: CharacterController:
	get: return player.character_controller
	set(_foo): push_error("readonly variable")
var camera: TopDownCamera:
	get: return player.camera
	set(_foo): push_error("readonly variable")
var interaction_area: InteractionArea:
	get: return player.interaction_area
	set(_foo): push_error("readonly variable")
var direction_input: Vector2:
	get: return player.direction_input
	set(_foo): push_error("readonly variable")
var interaction_input: StringName:
	get: return player.interaction_input
	set(_foo): push_error("readonly variable")
var available_action: CharacterInteraction:
	get: return player.available_action
	set(_foo): push_error("readonly variable")

func apply_input_direction(delta: float, to_character_controller: CharacterController = character_controller) -> void:
	assert(to_character_controller)
	var move_speed: float = to_character_controller.character.move_speed
	var acceleration: float = to_character_controller.character.acceleration * delta
	var deceleration: float = to_character_controller.character.deceleration * delta
	var velocity: Vector3 = to_character_controller.velocity
	if player.direction_input:
		var adjusted_direction_input: Vector2 = player.camera.get_adjusted_movement(player.direction_input)
		velocity.x = move_toward(velocity.x, adjusted_direction_input.x * move_speed, acceleration)
		velocity.z = move_toward(velocity.z, adjusted_direction_input.y * move_speed, acceleration)
	else:
		velocity.x = move_toward(velocity.x, 0.0, deceleration)
		velocity.z = move_toward(velocity.z, 0.0, deceleration)
	to_character_controller.velocity = velocity

# TODO: Pathfinding
