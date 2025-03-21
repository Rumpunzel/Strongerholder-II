class_name CharacterController
extends CharacterBody3D

@export var movement_attributes: MovementAttributes
@export var character_model: CharacterModel

var direction_input := Vector2.ZERO
var look_target := Vector3.BACK

var _is_on_floor := true
var _normalized_velocity := Vector3.ZERO

var _gravity: float = ProjectSettings.get_setting("physics/3d/default_gravity")

func _physics_process(delta: float) -> void:
	_apply_direction_input(delta)
	if character_model: character_model.play_animation(_normalized_velocity)

func _apply_direction_input(delta: float) -> void:
	if not multiplayer.is_server(): return
	_is_on_floor = is_on_floor()
	if not _is_on_floor: _apply_gravity(delta)
	var move_speed := movement_attributes.move_speed
	if direction_input:
		velocity.x = direction_input.x * move_speed
		velocity.z = direction_input.y * move_speed
	else:
		velocity.x = move_toward(velocity.x, 0.0, move_speed)
		velocity.z = move_toward(velocity.z, 0.0, move_speed)
	move_and_slide()
	if velocity: _look_forward(delta)
	_normalized_velocity = Vector3(velocity.x / move_speed, velocity.y / _gravity, velocity.z / move_speed)

func _apply_gravity(delta: float) -> void:
	velocity.y -= _gravity * delta

func _look_forward(delta: float) -> void:
	look_target = position + velocity
	look_target.y = position.y
	var transform_looking_into_direction := transform.looking_at(look_target, Vector3.UP, true)
	transform = transform.interpolate_with(transform_looking_into_direction, movement_attributes.turn_rate * delta)
