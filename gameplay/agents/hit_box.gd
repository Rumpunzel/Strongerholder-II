@tool
@icon("uid://bv63hb5gynt8d")
class_name HitBox
extends Area3D

@export var character_controller: CharacterController:
	set(new_character_controller):
		character_controller = new_character_controller
		_check_enabled()
		if not character_controller:
			character = null
			_world_character = null
			return
		character = character_controller.character
		_world_character = character_controller.world_character

@export var _ignore_areas_from_same_character_controller: bool = true

@export_group("Configuration")
@export var _collision_shape: CollisionShape3D

var character: Character:
	set(new_character):
		character = new_character
		if not character:
			_collision_shape.shape = null
			_collision_shape.position = Vector3.ZERO
			return
		collision_layer = character.hit_box_layer
		character.hit_box_shape.configure_collision_shape(_collision_shape)

var _world_character: WorldCharacter

func apply_material_override(material: Material) -> void:
	if not _world_character: return
	_world_character.apply_material_override(material)

func apply_material_overlay(material: Material) -> void:
	if not _world_character: return
	_world_character.apply_material_overlay(material)

func _check_enabled() -> void:
	if Engine.is_editor_hint(): return
	var is_enabled: bool = character_controller != null
	monitoring = is_enabled
	monitorable = is_enabled
	if _collision_shape: _collision_shape.disabled = not is_enabled

func _is_ignored(hit_box: HitBox) -> bool:
	return _ignore_areas_from_same_character_controller and hit_box.character_controller == character_controller

func _get_configuration_warnings() -> PackedStringArray:
	var warnings: PackedStringArray = [ ]
	if not _collision_shape: warnings.append("Missing CollisionShape3D reference.")
	return warnings
