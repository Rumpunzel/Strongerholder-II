class_name CharacterController
extends CharacterBody3D

@export var movement_attributes: MovementAttributes
@export var character_model: CharacterModel

var direction_input := Vector3.ZERO
var look_target := Vector3.BACK

var _gravity: float = ProjectSettings.get_setting("physics/3d/default_gravity")

func _physics_process(delta: float) -> void:
	if not multiplayer.is_server(): return
	apply_direction_input()
	if not is_on_floor(): apply_gravity(delta)
	move_and_slide()
	if velocity: look_forward(delta)
	if character_model: character_model.play_animation(velocity, movement_attributes.move_speed)

func apply_direction_input() -> void:
	var move_speed := movement_attributes.move_speed	
	if direction_input:
		velocity = direction_input * move_speed
	else:
		velocity.x = move_toward(velocity.x, 0, move_speed)
		velocity.z = move_toward(velocity.z, 0, move_speed)

func apply_gravity(delta: float) -> void:
	velocity.y -= _gravity * delta

func look_forward(delta: float) -> void:
	look_target = position + velocity
	look_target.y = position.y
	var transform_looking_into_direction := transform.looking_at(look_target, Vector3.UP, true)
	transform = transform.interpolate_with(transform_looking_into_direction, movement_attributes.turn_rate * delta)
