@tool
@icon("uid://bdsk0cjpq6pr4")
class_name CharacterController
extends CharacterBody3D

@export var character: Character:
	set(new_character):
		character = new_character
		if not character:
			name = "CharacterController"
			collision_layer = 2
			collision_mask = 3
			collision_shape = null
			world_character = null
			heads_up_anchor = null
			return
		name = character.name
		collision_layer = character.collision_layer
		collision_mask = character.collision_mask
		collision_shape = character.collision_shape.create_collision_shape()
		world_character = character.create_world_character()
		heads_up_anchor = character.create_heads_up_anchor()

var collision_shape: CollisionShape3D:
	set(new_collision_shape):
		if collision_shape:
			if get_children().has(collision_shape): remove_child(collision_shape)
			collision_shape.queue_free()
		collision_shape = new_collision_shape
		if not collision_shape: return
		add_child.call_deferred(collision_shape, true)

var world_character: WorldCharacter:
	set(new_world_character):
		if world_character:
			if get_children().has(world_character): remove_child(world_character)
			world_character.queue_free()
		world_character = new_world_character
		if not world_character: return
		add_child.call_deferred(world_character, true)

var heads_up_anchor: HeadsUpAnchor:
	set(new_heads_up_anchor):
		if heads_up_anchor:
			if get_children().has(heads_up_anchor): remove_child(heads_up_anchor)
			heads_up_anchor.queue_free()
		heads_up_anchor = new_heads_up_anchor
		if not heads_up_anchor: return
		add_child.call_deferred(heads_up_anchor, true)

var direction_input: Vector2 = Vector2.ZERO
var look_target: Vector3 = Vector3.BACK

var _normalized_velocity: Vector3 = Vector3.ZERO
var _is_on_floor: bool = true

var _gravity: float = ProjectSettings.get_setting("physics/3d/default_gravity")

## This is used for multiplayer purposes to synchronize over network; serves otherwise no purpose 
var _character_path: String:
	set(new_character_path):
		_character_path = new_character_path
		if character or _character_path.is_empty(): return
		assert(_character_path.is_absolute_path())
		character = load(_character_path)

func _physics_process(delta: float) -> void:
	if Engine.is_editor_hint(): return
	_apply_direction_input(delta)

func _process(_delta: float) -> void:
	if Engine.is_editor_hint(): return
	if world_character: world_character.play_animation(_normalized_velocity)

func _apply_direction_input(delta: float) -> void:
	_is_on_floor = is_on_floor()
	if not _is_on_floor: _apply_gravity(delta)
	var move_speed: float = character.move_speed
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
	var transform_looking_into_direction: Transform3D = transform.looking_at(look_target, Vector3.UP, true)
	transform = transform.interpolate_with(transform_looking_into_direction, character.turn_rate * delta)
