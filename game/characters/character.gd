@tool
@icon("uid://s227t8fljxxv")
class_name Character
extends Resource

@export var name: String
@export_color_no_alpha var color: Color
@export var movement_attributes: MovementAttributes

@export_category("World Character")
@export var collision_shape: Shape3D = preload("uid://c7hifnsy5vabh")
@export var hit_box_shape: Shape3D = preload("uid://h8f1hi4aoc40")
@export var interaction_area_shape: Shape3D = preload("uid://bn0pwy8h3w0s1")

@export var heads_up_display_height: float = 2.25

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

static func y_offset_from_shape(shape: Shape3D) -> float:
	if not shape: return 0.0
	var y_offset: float
	match shape.get_class():
		"BoxShape3D":
			var box_shape: BoxShape3D = shape
			y_offset = box_shape.size.y / 2.0
		"CapsuleShape3D":
			var capsule_shape: CapsuleShape3D = shape
			y_offset = capsule_shape.height / 2.0
		"ConcavePolygonShape3D": printerr("ConcavePolygonShape3D is not yet implemented!")
		"ConvexPolygonShape3D": printerr("ConvexPolygonShape3D is not yet implemented!")
		"CylinderShape3D":
			var cylinder_shape: CylinderShape3D = shape
			y_offset = cylinder_shape.height / 2.0
		"HeightMapShape3D": printerr("HeightMapShape3D is not yet implemented!")
		"SeparationRayShape3D": printerr("SeparationRayShape3D is not yet implemented!")
		"SphereShape3D":
			var sphere_shape: CylinderShape3D = shape
			y_offset = sphere_shape.radius
		"WorldBoundaryShape3D": printerr("WorldBoundaryShape3D is not yet implemented!")
	return y_offset
