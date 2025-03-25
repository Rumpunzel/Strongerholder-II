@tool
@icon("uid://bdsk0cjpq6pr4")
class_name CharacterController
extends CharacterBody3D

@export var character: Character:
	set(new_character):
		if character:
			remove_from_group(character.get_group_name())
		character = new_character
		if not character:
			name = "CharacterController"
			collision_layer = 2
			collision_mask = 3
			collision_shape = null
			world_character = null
			heads_up_anchor = null
			_hit_box.character = null
			return
		name = character.name
		add_to_group(character.get_group_name())
		collision_layer = character.collision_layer
		collision_mask = character.collision_mask
		collision_shape = character.collision_shape.create_collision_shape()
		world_character = character.create_world_character()
		heads_up_anchor = character.create_heads_up_anchor()
		_hit_box.character = character

@export_group("Configuration")
@export var _hit_box: HitBox

var collision_shape: CollisionShape3D:
	set(new_collision_shape):
		if collision_shape:
			collision_shape.queue_free()
		collision_shape = new_collision_shape
		if not collision_shape: return
		add_child(collision_shape, true)

var world_character: WorldCharacter:
	set(new_world_character):
		if world_character:
			world_character.queue_free()
		world_character = new_world_character
		if not world_character: return
		add_child(world_character, true)

var heads_up_anchor: HeadsUpAnchor:
	set(new_heads_up_anchor):
		if heads_up_anchor:
			heads_up_anchor.queue_free()
		heads_up_anchor = new_heads_up_anchor
		if not heads_up_anchor: return
		add_child(heads_up_anchor, true)

var look_target: Vector3 = Vector3.BACK

var _normalized_velocity: Vector3 = Vector3.ZERO
var _is_on_floor: bool = true

var _gravity: float = ProjectSettings.get_setting("physics/3d/default_gravity")

## This is used for serialization purposes; serves otherwise no purpose
var _character_path: String:
	get: return character.resource_path if character else ""
	set(new_character_path):
		_character_path = new_character_path
		if character or _character_path.is_empty(): return
		assert(_character_path.is_absolute_path())
		character = load(_character_path)

func _physics_process(delta: float) -> void:
	if Engine.is_editor_hint(): return
	_is_on_floor = is_on_floor()
	if not _is_on_floor: _apply_gravity(delta)
	move_and_slide()
	_look_forward(delta)
	_normalized_velocity = Vector3(velocity.x / character.move_speed, velocity.y / _gravity, velocity.z / character.move_speed)

func _process(_delta: float) -> void:
	if Engine.is_editor_hint(): return
	if world_character: world_character.play_animation(_normalized_velocity)

func _apply_gravity(delta: float) -> void:
	velocity.y -= _gravity * delta

func _look_forward(delta: float) -> void:
	look_target = position + velocity
	look_target.y = position.y
	if look_target.is_equal_approx(transform.origin): return
	var transform_looking_into_direction: Transform3D = transform.looking_at(look_target, Vector3.UP, true)
	transform = transform.interpolate_with(transform_looking_into_direction, character.turn_rate * delta)

func _get_configuration_warnings() -> PackedStringArray:
	var warnings: PackedStringArray = [ ]
	if not _hit_box: warnings.append("Missing HitBox reference.")
	return warnings
