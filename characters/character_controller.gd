@tool
class_name CharacterController
extends CharacterBody3D

@export var character: Character:
	set(new_character):
		character = new_character
		if not character:
			world_character = null
			_character_resource_path = ""
			return
		name = character.name
		world_character = character.get_world_character()
		_character_resource_path = character.resource_path

@export_group("Debug")
@export var _debug_world_character: PackedScene

var world_character: WorldCharacter:
	set(new_world_character):
		if world_character:
			remove_child(world_character)
			world_character.queue_free()
		world_character = new_world_character
		if not world_character:
			_world_character_scene_path = ""
			return
		add_child.call_deferred(world_character, true)
		_world_character_scene_path = new_world_character.scene_file_path

var direction_input := Vector2.ZERO
var look_target := Vector3.BACK

var _normalized_velocity := Vector3.ZERO
var _is_on_floor := true

var _gravity: float = ProjectSettings.get_setting("physics/3d/default_gravity")

# This is used for multiplayer purposes to synchronize over network
#  serves otherwise no purpose 
var _character_resource_path: String:
	set(new_character_resource_path):
		_character_resource_path = new_character_resource_path
		if character or _character_resource_path.is_empty(): return
		assert(_character_resource_path.is_absolute_path())
		character = load(_character_resource_path)

var _world_character_scene_path: String:
	set(new_world_character_scene_path):
		_world_character_scene_path = new_world_character_scene_path
		if world_character or _world_character_scene_path.is_empty(): return
		assert(_world_character_scene_path.is_absolute_path())
		var world_character_scene: PackedScene = load(_world_character_scene_path)
		world_character = world_character_scene.instantiate()

func _ready() -> void:
	if Engine.is_editor_hint():
		if _debug_world_character: _show_debug_world_character()

func _physics_process(delta: float) -> void:
	if Engine.is_editor_hint():
		pass
	else:
		_apply_direction_input(delta)

func _process(_delta: float) -> void:
	if Engine.is_editor_hint():
		pass
	else:
		if world_character: world_character.play_animation(_normalized_velocity)

func _apply_direction_input(delta: float) -> void:
	if multiplayer.has_multiplayer_peer() and not multiplayer.is_server(): return
	_is_on_floor = is_on_floor()
	if not _is_on_floor: _apply_gravity(delta)
	var move_speed := character.movement_attributes.move_speed
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
	transform = transform.interpolate_with(transform_looking_into_direction, character.movement_attributes.turn_rate * delta)

func _show_debug_world_character() -> void:
	assert(Engine.is_editor_hint())
	assert(_debug_world_character)
	world_character = _debug_world_character.instantiate()
