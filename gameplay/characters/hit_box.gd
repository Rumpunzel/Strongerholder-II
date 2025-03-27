@tool
@icon("uid://bv63hb5gynt8d")
class_name HitBox
extends Area3D

@export var character: Character:
	set(new_character):
		character = new_character
		_check_enabled()
		if not character:
			character_profile = null
			return
		character_profile = character.character_profile

@export var _ignore_areas_from_same_character: bool = true

@export_group("Configuration")
@export var _collision_shape: CollisionShape3D

var character_profile: CharacterProfile:
	set(new_character):
		character_profile = new_character
		if not character_profile:
			_collision_shape.shape = null
			_collision_shape.position = Vector3.ZERO
			return
		collision_layer = character_profile.hit_box_layer
		character_profile.hit_box_shape.configure_collision_shape(_collision_shape)

func apply_material_override(material: Material) -> void:
	if not character.character_model: return
	character.character_model.apply_material_override(material)

func apply_material_overlay(material: Material) -> void:
	if not character.character_model: return
	character.character_model.apply_material_overlay(material)

func _check_enabled() -> void:
	if Engine.is_editor_hint(): return
	var is_enabled: bool = character != null
	monitoring = is_enabled
	monitorable = is_enabled
	if _collision_shape: _collision_shape.disabled = not is_enabled

func _is_ignored(hit_box: HitBox) -> bool:
	return _ignore_areas_from_same_character and hit_box.character == character

func _get_configuration_warnings() -> PackedStringArray:
	var warnings: PackedStringArray = []
	if not _collision_shape: warnings.append("Missing CollisionShape3D reference.")
	return warnings
