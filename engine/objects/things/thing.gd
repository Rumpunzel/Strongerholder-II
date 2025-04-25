@tool
@icon("uid://whiw21f5vngd")
class_name Thing
extends RigidBody3D

signal profile_changed

const VARIATION: StringName = "variation"
const PROFILE_PATH: StringName = "profile_path"
const SPAWN_TRANSFORM: StringName = "spawn_transform"

const THING_SCENE: PackedScene = preload("uid://dnxaisin8ueu5")

## Determines the varation of the [Model]
## If [code]<0[/code] a random [Model] will be used
@export var variation: int = -1:
	set(new_variation):
		if new_variation == variation: return
		variation = new_variation
		if not model: return
		model = profile.create_model(variation)

@export var profile: ThingProfile:
	set(new_profile):
		profile = new_profile
		if not profile: return
		model = profile.create_model(variation)
		heads_up_anchor = profile.create_heads_up_anchor()
		profile.collision_shape.configure_collision_shape(_collision_shape)
		profile_changed.emit()
		if Engine.is_editor_hint(): return
		name = profile.name
		add_to_group(profile.get_group_name())

@export_group("Configuration")
@export var _collision_shape: CollisionShape3D

var model: Model:
	set(new_model):
		if model:
			remove_child(model)
			model.queue_free()
		model = new_model
		if not model: return
		add_child(model, true)

var heads_up_anchor: HeadsUpAnchor:
	set(new_heads_up_anchor):
		if heads_up_anchor:
			heads_up_anchor.queue_free()
		heads_up_anchor = new_heads_up_anchor
		if not heads_up_anchor: return
		add_child(heads_up_anchor, true)

var _is_on_floor: bool = true
var _normalized_velocity: Vector3 = Vector3.ZERO

var _gravity: float = ProjectSettings.get_setting("physics/3d/default_gravity")

func _ready() -> void:
	if Engine.is_editor_hint(): return

func _physics_process(delta: float) -> void:
	if Engine.is_editor_hint(): return
	#_is_on_floor = is_on_floor()
	#if not _is_on_floor: _apply_gravity(delta)
	#move_and_slide()
	#_look_forward(delta)
	#_normalized_velocity = Vector3(velocity.x / profile.move_speed, velocity.y / _gravity, velocity.z / profile.move_speed)

func _process(_delta: float) -> void:
	if Engine.is_editor_hint(): return
	if model: model.play_animation(_normalized_velocity, _is_on_floor)

static func create(new_variation: int, new_profile: ThingProfile, new_spawn_transform: Transform3D) -> Thing:
	var new_thing: Thing = THING_SCENE.instantiate()
	new_thing.variation = new_variation
	new_thing.profile = new_profile
	new_thing.transform = new_spawn_transform
	return new_thing

static func from_thing_data(thing_data: Dictionary[StringName, Variant]) -> Thing:
	validate_thing_data(thing_data)
	var new_variation: int = thing_data[VARIATION]
	var new_profile_path: String = thing_data[PROFILE_PATH]
	var new_profile: ThingProfile = load(new_profile_path)
	assert(new_profile)
	var new_spawn_transform: Transform3D = thing_data[SPAWN_TRANSFORM]
	return create(new_variation, new_profile, new_spawn_transform)

static func validate_thing_data(thing_data: Dictionary[StringName, Variant]) -> void:
	assert(thing_data.has_all([VARIATION, PROFILE_PATH, SPAWN_TRANSFORM]))
	assert(thing_data.size() == 3)

## Used to move the character without pathfinding
#@rpc("any_peer", "call_local")
#func apply_input_direction(direction_input: Vector2, delta: float) -> void:
	#var move_speed: float = profile.move_speed
	#var acceleration: float = profile.acceleration * delta
	#var deceleration: float = profile.deceleration * delta
	#if direction_input:
		#var adjusted_direction_input: Vector2 = direction_input
		#velocity.x = move_toward(velocity.x, adjusted_direction_input.x * move_speed, acceleration)
		#velocity.z = move_toward(velocity.z, adjusted_direction_input.y * move_speed, acceleration)
	#else:
		#velocity.x = move_toward(velocity.x, 0.0, deceleration)
		#velocity.z = move_toward(velocity.z, 0.0, deceleration)

func apply_thing_data(thing_data: Dictionary[StringName, Variant]) -> void:
	validate_thing_data(thing_data)
	variation = thing_data[VARIATION]
	var profile_path: String = thing_data[PROFILE_PATH]
	profile = load(profile_path)
	transform = thing_data[SPAWN_TRANSFORM]

func get_portrait() -> Texture:
	if model.portrait_override:
		return model.portrait_override
	return profile.portrait

#func _apply_gravity(delta: float) -> void:
	#velocity.y -= _gravity * delta
#
#func _look_forward(delta: float) -> void:
	#look_target = position + velocity
	#look_target.y = position.y
	#if look_target.is_equal_approx(transform.origin): return
	#var transform_looking_into_direction: Transform3D = transform.looking_at(look_target, Vector3.UP, true)
	#transform = transform.interpolate_with(transform_looking_into_direction, profile.turn_rate * delta)

func _on_haunted() -> void:
	model.apply_material_overlay(profile.haunted_material)

func _on_unhaunted() -> void:
	model.apply_material_overlay(null)

func _get_configuration_warnings() -> PackedStringArray:
	var warnings: PackedStringArray = []
	if not _collision_shape: warnings.append("Missing CollisionShape3D reference.")
	return warnings
