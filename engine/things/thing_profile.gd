@tool
@icon("uid://c4udocqr7qeyj")
class_name ThingProfile
extends Resource

@export var name: String
@export var portrait: Texture
@export_color_no_alpha var color: Color

@export_category("Attributes")
@export var density: float

@export_category("CharacterModel")
@export var collision_shape: CharacterAreaShape = preload("uid://d27l7tjgj4lrb")
@export var hit_box_shape: CharacterAreaShape = preload("uid://718wpxdsx3bo")
@export var haunted_material: Material = preload("uid://cmbf2wnye66jw")

@export_flags_3d_physics var hit_box_layer: int = 32
@export var heads_up_display_offset: Vector3 = Vector3(0.0, 2.0, 0.0)

@export var _character_model_variations: Array[PackedScene]

@export_group("Collision", "collision")
@export_flags_3d_physics var collision_layer: int = 2
@export_flags_3d_physics var collision_mask: int = 3

@export_category("")
@export_group("Configuration")
@export var _character_scene: PackedScene = preload("uid://cvj6b1m2b65hd")
@export var _heads_up_anchor_scene: PackedScene = preload("uid://cpmcbnpcemt61")

func create(variation: int, spawn_transform: Transform3D) -> Thing:
	var thing: Thing = _character_scene.instantiate()
	thing.variation = variation
	thing.character_profile = self
	thing.transform = spawn_transform
	return thing

func create_character_model(variation: int) -> CharacterModel:
	assert(not _character_model_variations.is_empty())
	var character_model: PackedScene
	if variation < 0:
		character_model = _character_model_variations.pick_random()
	else:
		assert(variation < _character_model_variations.size())
		character_model = _character_model_variations[variation]
	return character_model.instantiate()

func create_heads_up_anchor() -> HeadsUpAnchor:
	var heads_up_anchor: HeadsUpAnchor = _heads_up_anchor_scene.instantiate()
	heads_up_anchor.position = heads_up_display_offset
	return heads_up_anchor

func get_group_name() -> StringName:
	var group_name: StringName = Groups.keys()[group]
	return group_name.capitalize()

func _get_configuration_warnings() -> PackedStringArray:
	var warnings: PackedStringArray = []
	if _character_model_variations.is_empty(): warnings.append("Missing CharacterModel scene.")
	if not _character_scene: warnings.append("Missing Character scene.")
	if not _heads_up_anchor_scene: warnings.append("Missing Character scene.")
	return warnings
