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
		if not profile:
			assert(Engine.is_editor_hint())
			model = null
			_collision_shape.shape = null
			_collision_shape.position = Vector3.ZERO
			_collision_shape.rotation_degrees = Vector3.ZERO
			profile_changed.emit()
			return
		mass = profile.mass
		variation = profile.get_random_variation()
		model = profile.create_model(variation)
		profile.configure_collision_shape(_collision_shape)
		profile_changed.emit()
		if Engine.is_editor_hint():
			add_child(profile.create_heads_up_anchor())
			return
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

## This is used for serialization purposes; serves otherwise no purpose
@warning_ignore("unused_private_class_variable")
var _profile_path: String:
	get: return profile.resource_path
	set(new_profile_path):
		if profile and new_profile_path == profile.resource_path: return
		assert(not profile)
		profile = load(new_profile_path)

func _ready() -> void:
	if Engine.is_editor_hint(): return

#func _process(_delta: float) -> void:
	#if Engine.is_editor_hint(): return
	#if model: model.play_animation(_normalized_velocity, _is_on_floor)

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

@rpc("any_peer", "call_local")
func apply_input_force(input_force: Vector3) -> void:
	apply_central_force(input_force)

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

func get_heads_up_anchor() -> Vector3:
	return position + profile.heads_up_display_offset

func _on_haunted(_haunting: Character) -> void:
	model.apply_material_overlay(profile.haunted_material)

func _on_unhaunted() -> void:
	model.apply_material_overlay(null)

func _get_configuration_warnings() -> PackedStringArray:
	var warnings: PackedStringArray = []
	if not _collision_shape: warnings.append("Missing CollisionShape3D reference.")
	return warnings
