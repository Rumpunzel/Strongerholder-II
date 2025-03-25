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
@export var interaction_area_shape: CharacterAreaShape = preload("uid://3vtg05cuw32e")

@export var heads_up_display_offset: Vector3 = Vector3(0.0, 2.0, 0.0)

@export var _world_character: PackedScene
@export var _random_world_characters: Array[PackedScene]

@export_group("Collision", "collision")
@export_flags_3d_physics var collision_layer: int = 2
@export_flags_3d_physics var collision_mask: int = 3

@export_category("")
@export_group("Configuration")
@export var _character_controller_scene: PackedScene = preload("uid://cvj6b1m2b65hd")
@export var _heads_up_anchor_scene: PackedScene = preload("uid://cpmcbnpcemt61")

func create(spawn_transform: Transform3D) -> CharacterController:
	# XOR operator; either specific character XOR a random character
	assert(_world_character != null != not _random_world_characters.is_empty())
	var character_controller: CharacterController = create_dummy(spawn_transform)
	character_controller.character = self
	character_controller.transform = spawn_transform
	GameWorld.create_agent(character_controller)
	return character_controller

func create_dummy(spawn_transform: Transform3D) -> CharacterController:
	# XOR operator; either specific character XOR a random character
	assert(_world_character != null != not _random_world_characters.is_empty())
	var character_controller: CharacterController = _character_controller_scene.instantiate()
	character_controller.character = self
	character_controller.transform = spawn_transform
	return character_controller

func create_world_character() -> WorldCharacter:
	# XOR operator; either specific character XOR a random character
	assert(_world_character != null != not _random_world_characters.is_empty())
	if _world_character: return _world_character.instantiate()
	var random_world_character: PackedScene = _random_world_characters.pick_random()
	return random_world_character.instantiate()

func create_heads_up_anchor() -> HeadsUpAnchor:
	var heads_up_anchor: HeadsUpAnchor = _heads_up_anchor_scene.instantiate()
	heads_up_anchor.position = heads_up_display_offset
	return heads_up_anchor

func get_group_name() -> StringName:
	var group_name: StringName = Groups.keys()[group]
	return group_name.capitalize()

func _get_configuration_warnings() -> PackedStringArray:
	var warnings: PackedStringArray = [ ]
	if not _world_character and _random_world_characters.is_empty(): warnings.append("Missing WorldCharacter scene.")
	# XOR operator; either specific character XOR a random character
	if _world_character != null != not _random_world_characters.is_empty(): warnings.append("Either WorldCharacter XOR a random WorldCharacter.")
	if not _character_controller_scene: warnings.append("Missing CharacterController scene.")
	if not _heads_up_anchor_scene: warnings.append("Missing CharacterController scene.")
	return warnings
