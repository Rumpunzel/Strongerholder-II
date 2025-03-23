@tool
@icon("uid://s227t8fljxxv")
class_name Character
extends Resource

@export var name: String
@export_color_no_alpha var color: Color
@export var movement_attributes: MovementAttributes

@export_category("World Character")
@export var _world_character: PackedScene
@export var _random_world_characters: Array[PackedScene]

@export_group("Collision", "collision")
@export_flags_3d_physics var collision_layer: int = 2
@export_flags_3d_physics var collision_mask: int = 3

@export_category("")
@export_group("Character Controller")
@export var character_controller_scene: PackedScene = preload("uid://cvj6b1m2b65hd")

func create() -> CharacterController:
	assert(movement_attributes)
	# XOR operator; either specific character XOR a random character
	assert(_world_character != null != not _random_world_characters.is_empty())
	var character_controller: CharacterController = character_controller_scene.instantiate()
	character_controller.character = self
	return character_controller

func get_world_character() -> WorldCharacter:
	# XOR operator; either specific character XOR a random character
	assert(_world_character != null != not _random_world_characters.is_empty())
	if _world_character: return _world_character.instantiate()
	var random_world_character: PackedScene = _random_world_characters.pick_random()
	return random_world_character.instantiate()
