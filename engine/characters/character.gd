@tool
@icon("uid://bnaoddhf8gssj")
class_name Character
extends CharacterBody3D

signal haunted(haunted_character: Character, haunting_character: Character)
signal unhaunted(unhaunted_character: Character, unhaunting_character: Character)

const VARIATION: StringName = "variation"
const CHARACTER_PROFILE_PATH: StringName = "character_profile_path"
const SPAWN_LOCATION: StringName = "spawn_location"

## Determines the varation of the [CharacterModel]
## If [code]<0[/code] a random [CharacterModel] will be used
@export var variation: int = -1:
	set(new_variation):
		if new_variation == variation: return
		variation = new_variation
		if not character_model: return
		character_model = character_profile.create_character_model(variation)

@export var character_profile: CharacterProfile:
	set(new_character):
		if character_profile:
			remove_from_group(character_profile.get_group_name())
		character_profile = new_character
		_check_processing()
		if not character_profile:
			name = "Character"
			character_model = null
			heads_up_anchor = null
			_collision_shape.shape = null
			_collision_shape.position = Vector3.ZERO
			_hit_box.character_profile = null
			return
		name = character_profile.name
		add_to_group(character_profile.get_group_name())
		collision_layer = character_profile.collision_layer
		collision_mask = character_profile.collision_mask
		character_model = character_profile.create_character_model(variation)
		heads_up_anchor = character_profile.create_heads_up_anchor()
		if not is_node_ready(): await ready
		character_profile.collision_shape.configure_collision_shape(_collision_shape)
		_hit_box.character_profile = character_profile

@export_group("Configuration")
@export var _collision_shape: CollisionShape3D
@export var _hit_box: HitBox

var character_model: CharacterModel:
	set(new_character_model):
		if character_model:
			remove_child(character_model)
			character_model.queue_free()
		character_model = new_character_model
		if not character_model: return
		add_child(character_model, true)

var heads_up_anchor: HeadsUpAnchor:
	set(new_heads_up_anchor):
		if heads_up_anchor:
			heads_up_anchor.queue_free()
		heads_up_anchor = new_heads_up_anchor
		if not heads_up_anchor: return
		add_child(heads_up_anchor, true)

var look_target: Vector3 = Vector3.BACK

var _is_on_floor: bool = true
var _normalized_velocity: Vector3 = Vector3.ZERO

var _gravity: float = ProjectSettings.get_setting("physics/3d/default_gravity")

func _ready() -> void:
	if Engine.is_editor_hint(): return
	_check_processing()

func _physics_process(delta: float) -> void:
	if Engine.is_editor_hint(): return
	_is_on_floor = is_on_floor()
	if not _is_on_floor: _apply_gravity(delta)
	move_and_slide()
	_look_forward(delta)
	_normalized_velocity = Vector3(velocity.x / character_profile.move_speed, velocity.y / _gravity, velocity.z / character_profile.move_speed)

func _process(delta: float) -> void:
	if Engine.is_editor_hint(): return
	if character_model: character_model.play_animation(_normalized_velocity, _is_on_floor)

static func validate_character_data(character_data: Dictionary[StringName, Variant]) -> void:
	assert(character_data.has_all([VARIATION, CHARACTER_PROFILE_PATH, SPAWN_LOCATION]))
	assert(character_data.size() == 3)

@rpc("any_peer", "call_local")
func apply_velocity(velocity_to_apply: Vector3) -> void:
	velocity = velocity_to_apply

@rpc("any_peer", "call_local", "reliable")
func haunt(haunted_character_path: NodePath) -> void:
	var haunted_character: Character = get_node(haunted_character_path)
	assert(haunted_character)
	visible = false
	haunted_character.character_model.apply_material_overlay(character_profile.haunted_material)
	haunted.emit(haunted_character, self)

@rpc("any_peer", "call_local", "reliable")
func unhaunt(unhaunted_character_path: NodePath) -> void:
	var unhaunted_character: Character = get_node(unhaunted_character_path)
	assert(unhaunted_character)
	visible = true
	unhaunted_character.character_model.apply_material_overlay(null)
	unhaunted.emit(unhaunted_character, self)

func apply_character_data(character_data: Dictionary[StringName, Variant]) -> void:
	validate_character_data(character_data)
	variation = character_data[VARIATION]
	var character_profile_path: String = character_data[CHARACTER_PROFILE_PATH]
	character_profile = load(character_profile_path)
	transform = character_data[SPAWN_LOCATION]

func get_portrait() -> Texture:
	if character_model.portrait_override:
		return character_model.portrait_override
	return character_profile.portrait

func _apply_gravity(delta: float) -> void:
	velocity.y -= _gravity * delta

func _look_forward(delta: float) -> void:
	look_target = position + velocity
	look_target.y = position.y
	if look_target.is_equal_approx(transform.origin): return
	var transform_looking_into_direction: Transform3D = transform.looking_at(look_target, Vector3.UP, true)
	transform = transform.interpolate_with(transform_looking_into_direction, character_profile.turn_rate * delta)

func _check_processing() -> void:
	var enabled: bool = character_profile != null
	set_process(enabled)
	set_physics_process(enabled)

func _get_configuration_warnings() -> PackedStringArray:
	var warnings: PackedStringArray = []
	if not _collision_shape: warnings.append("Missing CollisionShape3D reference.")
	if not _hit_box: warnings.append("Missing HitBox reference.")
	return warnings
