@tool
@icon("uid://jbvl50k3l8k3")
class_name Character
extends Resource

enum Groups {
	PEOPLE,
	GHOSTS,
}

@export var name: String
@export_color_no_alpha var color: Color
@export var group: Groups = Groups.PEOPLE

@export_category("Attributes")
@export var move_speed: float = 8.0
@export var acceleration: float = 32.0
@export var turn_rate: float = 12.0

@export_category("World Character")
@export var collision_shape: CharacterAreaShape = preload("uid://d27l7tjgj4lrb")
@export var hit_box_shape: CharacterAreaShape = preload("uid://718wpxdsx3bo")
@export_flags_3d_physics var hit_box_layer: int = 32
@export var interaction_area_shape: CharacterAreaShape = preload("uid://3vtg05cuw32e")

@export var heads_up_display_offset: Vector3 = Vector3(0.0, 2.0, 0.0)

@export var _character_model: PackedScene
@export var _random_character_models: Array[PackedScene]

@export_group("Collision", "collision")
@export_flags_3d_physics var collision_layer: int = 2
@export_flags_3d_physics var collision_mask: int = 3

@export_category("")
@export_group("Configuration")
@export var _character_controller_scene: PackedScene = preload("uid://cvj6b1m2b65hd")
@export var _heads_up_anchor_scene: PackedScene = preload("uid://cpmcbnpcemt61")

func create(spawn_transform: Transform3D) -> CharacterController:
	# XOR operator; either specific character XOR a random character
	assert(_character_model != null != not _random_character_models.is_empty())
	var character_controller: CharacterController = create_dummy(spawn_transform)
	character_controller.character = self
	character_controller.transform = spawn_transform
	Gameplay.request_agent_for_character_controller.emit(character_controller)
	return character_controller

func create_dummy(spawn_transform: Transform3D) -> CharacterController:
	# XOR operator; either specific character XOR a random character
	assert(_character_model != null != not _random_character_models.is_empty())
	var character_controller: CharacterController = _character_controller_scene.instantiate()
	character_controller.character = self
	character_controller.transform = spawn_transform
	return character_controller

func create_character_model() -> CharacterModel:
	# XOR operator; either specific character XOR a random character
	assert(_character_model != null != not _random_character_models.is_empty())
	if _character_model: return _character_model.instantiate()
	var random_character_model: PackedScene = _random_character_models.pick_random()
	return random_character_model.instantiate()

func create_heads_up_anchor() -> HeadsUpAnchor:
	var heads_up_anchor: HeadsUpAnchor = _heads_up_anchor_scene.instantiate()
	heads_up_anchor.position = heads_up_display_offset
	return heads_up_anchor

func get_group_name() -> StringName:
	var group_name: StringName = Groups.keys()[group]
	return group_name.capitalize()

func _get_configuration_warnings() -> PackedStringArray:
	var warnings: PackedStringArray = []
	if not _character_model and _random_character_models.is_empty(): warnings.append("Missing CharacterModel scene.")
	# XOR operator; either specific character XOR a random character
	if _character_model != null != not _random_character_models.is_empty(): warnings.append("Either CharacterModel XOR a random CharacterModel.")
	if not _character_controller_scene: warnings.append("Missing CharacterController scene.")
	if not _heads_up_anchor_scene: warnings.append("Missing CharacterController scene.")
	return warnings
