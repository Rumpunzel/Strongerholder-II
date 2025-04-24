@tool
@icon("uid://c8dtrg5rbcbl5")
class_name CharacterSpawner
extends Spawner

@export_group("Configuration")

func _enter_tree() -> void:
	if Engine.is_editor_hint(): return
	spawn_function = _spawn_character

func _ready() -> void:
	super._ready()

func _spawn_character(character_data: Dictionary[StringName, Variant]) -> Character:
	Character.validate_character_data(character_data)
	var variation: int = character_data[Character.VARIATION]
	var character_profile_path: String = character_data[Character.CHARACTER_PROFILE_PATH]
	var spawn_location: Transform3D = character_data[Character.SPAWN_LOCATION]
	var character_profile: CharacterProfile = load(character_profile_path)
	assert(character_profile)
	var character: Character = character_profile.create(variation, spawn_location)
	assert(character)
	return character

func _get_configuration_warnings() -> PackedStringArray:
	var warnings: PackedStringArray = []
	return warnings
