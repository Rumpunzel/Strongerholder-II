@tool
@icon("uid://btd64iwc2p3sh")
class_name CharacterProfile
extends Profile

enum Groups {
	PEOPLE,
	GHOSTS,
}

@export var group: Groups = Groups.PEOPLE

@export_category("Attributes")
@export var move_speed: float = 8.0
@export var acceleration: float = 32.0
@export var deceleration: float = 32.0
@export var turn_rate: float = 12.0

@export var interaction_area_shape: AreaShape = preload("uid://3vtg05cuw32e")

@export_category("")
@export_group("Configuration")

func create(variation: int, spawn_transform: Transform3D) -> Character:
	var new_character: Character = PackedScenes.CHARACTER_SCENE.instantiate()
	new_character.variation = variation
	new_character.profile = self
	new_character.transform = spawn_transform
	return new_character

func get_group_name() -> StringName:
	var group_name: StringName = Groups.keys()[group]
	return group_name.capitalize()

func _get_configuration_warnings() -> PackedStringArray:
	var warnings: PackedStringArray = []
	if _model_variations.is_empty(): warnings.append("Missing model variations scene.")
	return warnings + super._get_configuration_warnings()
